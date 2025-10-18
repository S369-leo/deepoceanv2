import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:deep_ocean_v2/controllers/theme_mode_controller.dart';
import 'package:deep_ocean_v2/data/chat_memory_store.dart';
import 'package:deep_ocean_v2/data/likes_repository.dart';
import 'package:deep_ocean_v2/data/user_prefs.dart';
import 'package:deep_ocean_v2/main.dart';
import 'package:deep_ocean_v2/models/profile_lite.dart';
import 'package:deep_ocean_v2/models/user_profile.dart';
import 'package:deep_ocean_v2/screens/chat_page.dart';

Future<void> _pumpApp(
  WidgetTester tester,
  LikesRepository likesRepository,
  ThemeModeController themeController,
  ChatMemoryStore chatStore,
  UserPrefs userPrefs,
) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: likesRepository),
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider.value(value: chatStore),
        ChangeNotifierProvider.value(value: userPrefs),
      ],
      child: const DeepOceanApp(),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 120));
}

Future<void> _openChatForFirstMatch(WidgetTester tester) async {
  await tester.tap(find.text('Matches'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 120));

  await tester.tap(find.byIcon(Icons.chat_bubble).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

UserPrefs _buildUserPrefs() {
  final prefs = UserPrefs();
  return prefs;
}

Future<UserPrefs> _initUserPrefs() async {
  final prefs = _buildUserPrefs();
  await prefs.hydrate();
  await prefs.setFirstRunFalse();
  if (!prefs.hasProfile) {
    await prefs.saveProfile(
      UserProfile(
        name: 'Test User',
        age: 28,
        bio: 'Placeholder bio for chat tests.',
        gender: 'Non-binary',
        lookingFor: 'Everyone',
        interests: const <String>['Testing'],
        photos: const <String>['assets/images/profiles/profile_01.jpg'],
      ),
    );
  }
  return prefs;
}

void main() {
  testWidgets('ChatPage opens and accepts input', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final likesRepository = LikesRepository();
    likesRepository.addLike(
      ProfileLite(
        id: 'p1',
        name: 'Alex Rivers',
        age: 29,
        gender: 'Non-binary',
        imageAsset: 'assets/images/profiles/profile_01.jpg',
      ),
    );

    final themeController = ThemeModeController();
    await themeController.hydrate();
    final chatStore = ChatMemoryStore();
    final userPrefs = await _initUserPrefs();

    await _pumpApp(
      tester,
      likesRepository,
      themeController,
      chatStore,
      userPrefs,
    );
    await _openChatForFirstMatch(tester);

    expect(find.byType(ChatPage), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('chat-input-field')),
      'Hi Alex!',
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Hi Alex!'), findsOneWidget);

    final TextField input = tester.widget(
      find.byKey(const ValueKey('chat-input-field')),
    );
    expect(input.controller?.text ?? '', isEmpty);
  });

  testWidgets('ChatPage keeps messages across tab switches', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final likesRepository = LikesRepository();
    likesRepository.addLike(
      ProfileLite(
        id: 'p1',
        name: 'Alex Rivers',
        age: 29,
        gender: 'Non-binary',
        imageAsset: 'assets/images/profiles/profile_01.jpg',
      ),
    );

    final themeController = ThemeModeController();
    await themeController.hydrate();
    final chatStore = ChatMemoryStore();
    final userPrefs = await _initUserPrefs();

    await _pumpApp(
      tester,
      likesRepository,
      themeController,
      chatStore,
      userPrefs,
    );
    await _openChatForFirstMatch(tester);

    expect(find.byType(ChatPage), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('chat-input-field')),
      'Hello there',
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final TextField input = tester.widget(
      find.byKey(const ValueKey('chat-input-field')),
    );
    expect(input.controller?.text ?? '', isEmpty);
    expect(find.text('Hello there'), findsOneWidget);

    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    await tester.tap(find.text('Explore'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    await tester.tap(find.text('Matches'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    await tester.tap(find.byIcon(Icons.chat_bubble).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(ChatPage), findsOneWidget);

    final Finder chatList = find.descendant(
      of: find.byType(ChatPage),
      matching: find.byType(ListView),
    );
    await tester.drag(chatList, const Offset(0, -300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('Hello there'), findsOneWidget);
  });
}
