import 'package:deep_ocean_v2/main.dart' as app;
import 'package:deep_ocean_v2/widgets/swipe_deck.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _startApp(WidgetTester tester) async {
  await app.main();
  await tester.pumpAndSettle();
}

Future<void> _restartApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await app.main();
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('likes persist, theme survives restart, deck reset safe',
      (WidgetTester tester) async {
    await _startApp(tester);

    expect(find.text('Discover'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();
    expect(find.text('Noah Smith, 27 - Male'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    final Finder themeDropdown =
        find.byKey(const ValueKey('theme-mode-dropdown'));
    await tester.tap(themeDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();

    final MaterialApp appWidget =
        tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(appWidget.themeMode, ThemeMode.dark);

    await _restartApp(tester);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();
    expect(find.text('Noah Smith, 27 - Male'), findsOneWidget);

    final MaterialApp appAfterRestart =
        tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(appAfterRestart.themeMode, ThemeMode.dark);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    final DropdownButton<ThemeMode> dropdownWidget =
        tester.widget<DropdownButton<ThemeMode>>(themeDropdown);
    expect(dropdownWidget.value, ThemeMode.dark);

    await tester.tap(find.byIcon(Icons.explore_outlined));
    await tester.pumpAndSettle();

    final Finder skipButton = find.byIcon(Icons.close_rounded);
    for (var i = 0; i < 12; i++) {
      if (find.text("You're all caught up").evaluate().isNotEmpty) {
        break;
      }
      if (!tester.any(skipButton)) {
        break;
      }
      await tester.tap(skipButton);
      await tester.pumpAndSettle();
    }

    expect(find.text("You're all caught up"), findsOneWidget);
    expect(find.text('Reset deck'), findsOneWidget);

    await tester.tap(find.text('Reset deck'));
    await tester.pumpAndSettle();

    expect(find.byType(SwipeDeck), findsOneWidget);
  });
}
