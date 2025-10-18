import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:deep_ocean_v2/controllers/theme_mode_controller.dart';
import 'package:deep_ocean_v2/data/chat_memory_store.dart';
import 'package:deep_ocean_v2/data/likes_repository.dart';
import 'package:deep_ocean_v2/screens/settings_page.dart';

Future<void> _pumpSettingsPage(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});

  final likesRepository = LikesRepository();
  await likesRepository.hydrate();
  final themeController = ThemeModeController();
  await themeController.hydrate();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: likesRepository),
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider(create: (_) => ChatMemoryStore()),
      ],
      child: const MaterialApp(home: SettingsPage()),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  while (tester.any(find.byType(CircularProgressIndicator))) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _openTile(WidgetTester tester, Finder tile) async {
  await tester.scrollUntilVisible(tile, 200);
  await tester.tap(tile);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('navigates to Terms of Service page from settings', (WidgetTester tester) async {
    await _pumpSettingsPage(tester);

    final termsTile = find.text('Terms of Service');
    await _openTile(tester, termsTile);

    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Welcome to Deep Ocean'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
  });

  testWidgets('navigates to Privacy Policy page from settings', (WidgetTester tester) async {
    await _pumpSettingsPage(tester);

    final privacyTile = find.text('Privacy Policy');
    await _openTile(tester, privacyTile);

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('How we handle your data'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
  });

  testWidgets('navigates to About page from settings', (WidgetTester tester) async {
    await _pumpSettingsPage(tester);

    final aboutTile = find.text('About Deep Ocean');
    await _openTile(tester, aboutTile);

    expect(find.text('About Deep Ocean'), findsOneWidget);
    expect(find.text('Deep Ocean Dating'), findsOneWidget);
  });
}
