import 'package:flutter_test/flutter_test.dart';

import 'package:deep_ocean_v2/data/feed_filter.dart';
import 'package:deep_ocean_v2/data/user_prefs.dart';
import 'package:deep_ocean_v2/models/profile_lite.dart';
import 'package:deep_ocean_v2/models/user_profile.dart';

class _FakeUserPrefs extends UserPrefs {
  _FakeUserPrefs(this._profile);

  final UserProfile? _profile;

  @override
  UserProfile? get profile => _profile;

  @override
  bool get hasProfile => _profile != null;
}

void main() {
  const FeedFilter filter = FeedFilter();

  group('FeedFilter', () {
    test('filters by lookingFor women', () {
      final _FakeUserPrefs prefs = _FakeUserPrefs(
        UserProfile(
          name: 'Sam',
          age: 29,
          bio: 'Testing preferences',
          gender: 'man',
          lookingFor: 'women',
          interests: const <String>[],
          photos: const <String>[],
        ),
      );

      final List<ProfileLite> profiles = <ProfileLite>[
        ProfileLite(
          id: 'male-1',
          name: 'Max',
          age: 30,
          gender: 'Male',
          photos: const <String>['assets/images/profiles/profile_04.jpg'],
        ),
        ProfileLite(
          id: 'f1',
          name: 'Lily',
          age: 28,
          gender: 'Female',
          photos: const <String>['assets/images/profiles/profile_05.jpg'],
        ),
      ];

      final List<ProfileLite> result = filter.apply(profiles, prefs);

      expect(result, hasLength(1));
      expect(result.single.id, equals('f1'));
    });

    test('profiles sharing interests appear first', () {
      final _FakeUserPrefs prefs = _FakeUserPrefs(
        UserProfile(
          name: 'Jess',
          age: 27,
          bio: 'Enjoying the app',
          gender: 'woman',
          lookingFor: 'everyone',
          interests: const <String>['Travel', 'Music'],
          photos: const <String>[],
        ),
      );

      final List<ProfileLite> profiles = <ProfileLite>[
        ProfileLite(
          id: 'u5',
          name: 'Lana Ortiz',
          age: 28,
          gender: 'Female',
          photos: const <String>['assets/images/profiles/profile_05.jpg'],
        ),
        ProfileLite(
          id: 'u7',
          name: 'Ethan Brown',
          age: 32,
          gender: 'Male',
          photos: const <String>['assets/images/profiles/profile_07.jpg'],
        ),
        ProfileLite(
          id: 'u4',
          name: 'Henry Foster',
          age: 30,
          gender: 'Male',
          photos: const <String>['assets/images/profiles/profile_04.jpg'],
        ),
        ProfileLite(
          id: 'u6',
          name: 'Sasha Patel',
          age: 29,
          gender: 'Non-binary',
          photos: const <String>['assets/images/profiles/profile_06.jpg'],
        ),
      ];

      final List<ProfileLite> result = filter.apply(profiles, prefs);

      expect(result.map((profile) => profile.id).toList(),
          equals(<String>['u7', 'u4', 'u5', 'u6']));
    });
  });
}
