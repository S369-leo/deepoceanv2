import 'dart:convert';

import 'package:deep_ocean_v2/data/likes_repository.dart';
import 'package:deep_ocean_v2/models/profile_lite.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final sample = ProfileLite(
    id: 'test-id',
    name: 'Sample User',
    age: 29,
    gender: 'Non-binary',
    imageAsset: 'assets/images/profiles/profile_01.jpg',
  );

  Future<void> pumpMicrotasks() => Future<void>.delayed(Duration.zero);

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('addLike deduplicates stored likes', () async {
    final repo = LikesRepository();
    expect(await repo.hydrate(), isFalse);

    expect(repo.addLike(sample), isTrue);
    expect(repo.addLike(sample), isFalse);
    await pumpMicrotasks();

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('likes_v1');
    expect(stored, isNotNull);

    final Map<String, dynamic> decoded =
        Map<String, dynamic>.from(jsonDecode(stored!) as Map);
    final List<dynamic> likes = List<dynamic>.from(decoded['likes'] as List);
    expect(likes.length, 1);
    final map = Map<String, dynamic>.from(likes.first as Map);
    expect(map['id'], sample.id);
    expect(map['imageAsset'], sample.imageAsset);
  });

  test('removeLike updates persistence', () async {
    final repo = LikesRepository();
    expect(await repo.hydrate(), isFalse);
    repo.addLike(sample);
    await pumpMicrotasks();

    expect(repo.removeLike(sample.id), isTrue);
    await pumpMicrotasks();

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString('likes_v1'),
      jsonEncode(<String, dynamic>{'likes': <dynamic>[]}),
    );
    expect(repo.likes, isEmpty);
  });

  test('clear removes all likes and persists', () async {
    final repo = LikesRepository();
    expect(await repo.hydrate(), isFalse);
    repo
      ..addLike(sample)
      ..addLike(ProfileLite(
        id: 'another-id',
        name: 'Another User',
        age: 33,
        gender: 'Female',
        imageAsset: 'assets/images/profiles/profile_02.jpg',
      ));
    await pumpMicrotasks();

    expect(repo.clear(), isTrue);
    await pumpMicrotasks();

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString('likes_v1'),
      jsonEncode(<String, dynamic>{'likes': <dynamic>[]}),
    );
    expect(repo.likes, isEmpty);
  });

  test('hydrate restores previously saved likes', () async {
    final payload = jsonEncode(<String, dynamic>{
      'likes': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': sample.id,
          'name': sample.name,
          'age': sample.age,
          'gender': sample.gender,
          'localImagePath': sample.imageAsset,
        },
      ],
    });
    SharedPreferences.setMockInitialValues(<String, Object>{
      'likes_v1': payload,
    });

    final repo = LikesRepository();
    expect(await repo.hydrate(), isTrue);

    expect(repo.likes.length, 1);
    expect(repo.likes.first.id, sample.id);
    expect(repo.likes.first.imageAsset, sample.imageAsset);
  });

  test('hydrate skips invalid or duplicate entries safely', () async {
    final payload = jsonEncode(<String, dynamic>{
      'likes': <dynamic>[
        <String, dynamic>{
          'id': sample.id,
          'name': sample.name,
          'age': sample.age,
          'gender': sample.gender,
          'imageAsset': sample.imageAsset,
        },
        <String, dynamic>{
          'id': sample.id,
          'name': 'Duplicate User',
          'age': sample.age,
          'gender': sample.gender,
          'imageAsset': sample.imageAsset,
        },
        <String, dynamic>{
          'id': 'missing-age',
          'name': 'No Age',
          'gender': 'Female',
          'imageAsset': sample.imageAsset,
        },
        'unexpected',
      ],
    });

    SharedPreferences.setMockInitialValues(<String, Object>{
      'likes_v1': payload,
    });

    final repo = LikesRepository();
    expect(await repo.hydrate(), isTrue);
    expect(repo.likes.length, 1);
    expect(repo.likes.first.id, sample.id);
  });
}

