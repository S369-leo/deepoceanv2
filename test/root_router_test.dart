import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:deep_ocean_v2/controllers/theme_mode_controller.dart';
import 'package:deep_ocean_v2/data/chat_memory_store.dart';
import 'package:deep_ocean_v2/data/likes_repository.dart';
import 'package:deep_ocean_v2/data/user_prefs.dart';
import 'package:deep_ocean_v2/main.dart';
import 'package:deep_ocean_v2/screens/home_shell.dart';
import 'package:deep_ocean_v2/screens/info/safety_tips_page.dart';
import 'package:deep_ocean_v2/screens/onboarding/onboarding_flow.dart';

void main() {
  testWidgets('first run shows onboarding flow', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final userPrefs = UserPrefs();
    await userPrefs.hydrate();

    await tester.pumpWidget(
      ChangeNotifierProvider<UserPrefs>.value(
        value: userPrefs,
        child: MaterialApp(
          routes: {
            SafetyTipsPage.routeName: (context) => const SafetyTipsPage(),
          },
          home: const RootRouter(),
        ),
      ),
    );
    await tester.pump();
    for (int i = 0; i < 8 && find.byType(OnboardingFlow).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }

    expect(find.byType(OnboardingFlow), findsOneWidget);
  });

  testWidgets('subsequent runs show home shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'user_first_run_v1': false,
    });

    final userPrefs = UserPrefs();
    await userPrefs.hydrate();
    final likesRepository = LikesRepository();
    await likesRepository.hydrate();
    final themeController = ThemeModeController();
    await themeController.hydrate();
    final chatStore = ChatMemoryStore();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserPrefs>.value(value: userPrefs),
          ChangeNotifierProvider<LikesRepository>.value(value: likesRepository),
          ChangeNotifierProvider<ThemeModeController>.value(value: themeController),
          ChangeNotifierProvider<ChatMemoryStore>.value(value: chatStore),
        ],
        child: MaterialApp(
          routes: {
            SafetyTipsPage.routeName: (context) => const SafetyTipsPage(),
          },
          home: const RootRouter(),
        ),
      ),
    );
    await tester.pump();
    for (int i = 0; i < 8 && find.byType(HomeShell).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }

    expect(find.byType(HomeShell), findsOneWidget);
  });
}

