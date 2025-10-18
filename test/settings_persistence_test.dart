import 'dart:convert';

import 'package:deep_ocean_v2/controllers/theme_mode_controller.dart';
import 'package:deep_ocean_v2/data/likes_repository.dart';
import 'package:deep_ocean_v2/models/profile_lite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpMicrotasks() => Future<void>.delayed(Duration.zero);

void main() {
  final sample = ProfileLite(
    id: 'sample-id',
    name: 'Sample User',
    age: 28,
    gender: 'Non-binary',
    imageAsset: 'assets/images/profiles/profile_01.jpg',
  );

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('theme mode selection persists across sessions', () async {
    final controller = ThemeModeController();
    await controller.hydrate();

    await controller.setThemeMode(ThemeMode.dark);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('settings_theme_mode'), 'dark');
  });

  test('reset likes clears stored likes in preferences', () async {
    final payload = jsonEncode(<String, dynamic>{
      'likes': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': sample.id,
          'name': sample.name,
          'age': sample.age,
          'gender': sample.gender,
          'imageAsset': sample.imageAsset,
        },
      ],
    });

    SharedPreferences.setMockInitialValues(<String, Object>{
      'likes_v1': payload,
    });

    final repo = LikesRepository();
    expect(await repo.hydrate(), isTrue);
    expect(repo.likes, isNotEmpty);

    expect(repo.clear(), isTrue);
    await _pumpMicrotasks();

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString('likes_v1'),
      jsonEncode(<String, dynamic>{'likes': <dynamic>[]}),
    );
    expect(repo.likes, isEmpty);
  });
}
