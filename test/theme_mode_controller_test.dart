import 'package:deep_ocean_v2/controllers/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('hydrate reads stored theme mode value', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'settings_theme_mode': 'dark',
    });

    final controller = ThemeModeController();
    await controller.hydrate();

    expect(controller.themeMode, ThemeMode.dark);
    expect(controller.isHydrated, isTrue);
  });

  test('setThemeMode persists and notifies', () async {
    final controller = ThemeModeController();
    await controller.hydrate();

    expect(controller.themeMode, ThemeMode.system);

    var notified = false;
    controller.addListener(() => notified = true);

    await controller.setThemeMode(ThemeMode.light);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('settings_theme_mode'), 'light');
    expect(controller.themeMode, ThemeMode.light);
    expect(notified, isTrue);
  });
}
