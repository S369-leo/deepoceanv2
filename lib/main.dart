import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/theme_mode_controller.dart';
import 'data/chat_memory_store.dart';
import 'data/likes_repository.dart';
import 'data/user_prefs.dart';
import 'screens/home_shell.dart';
import 'screens/info/safety_tips_page.dart';
import 'screens/onboarding/onboarding_flow.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(() {
    final FlutterExceptionHandler? previousHandler = FlutterError.onError;
    final FlutterExceptionHandler? forwardingHandler =
        previousHandler != null &&
                !identical(previousHandler, FlutterError.presentError)
            ? previousHandler
            : null;

    FlutterError.onError = (FlutterErrorDetails details) {
      final String summary = details.exceptionAsString();
      debugPrint('FlutterError: $summary');

      final StackTrace? stackTrace = details.stack;
      if (stackTrace != null) {
        const int maxLines = 5;
        final List<String> lines = stackTrace
            .toString()
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList(growable: false);
        final int linesToPrint =
            lines.length < maxLines ? lines.length : maxLines;
        for (var i = 0; i < linesToPrint; i++) {
          debugPrint('  ${lines[i]}');
        }
        if (lines.length > maxLines) {
          debugPrint('  ...');
        }
      }

      if (forwardingHandler != null) {
        forwardingHandler(details);
      } else {
        Zone.current.handleUncaughtError(
          details.exception,
          stackTrace ?? StackTrace.empty,
        );
      }
    };
    return true;
  }());

  final likesRepository = LikesRepository();
  await likesRepository.hydrate();

  final themeModeController = ThemeModeController();
  await themeModeController.hydrate();

  final chatMemoryStore = ChatMemoryStore();
  final userPrefs = UserPrefs();
  await userPrefs.hydrate();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: likesRepository),
        ChangeNotifierProvider.value(value: themeModeController),
        ChangeNotifierProvider.value(value: chatMemoryStore),
        ChangeNotifierProvider.value(value: userPrefs),
      ],
      child: const DeepOceanApp(),
    ),
  );
}

class DeepOceanApp extends StatelessWidget {
  const DeepOceanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeModeController>().themeMode;

    return MaterialApp(
      title: 'Deep Ocean Dating',
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routes: {
        SafetyTipsPage.routeName: (context) => const SafetyTipsPage(),
      },
      home: const RootRouter(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RootRouter extends StatelessWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPrefs>(
      builder: (context, prefs, _) {
        if (!prefs.isHydrated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (prefs.isFirstRun) {
          return const OnboardingFlow();
        }
        return const HomeShell();
      },
    );
  }
}

