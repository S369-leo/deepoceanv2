import '../models/profile_lite.dart';
import 'user_prefs.dart';

class FeedFilter {
  const FeedFilter({Map<String, List<String>>? interestsByProfile})
      : _interestsByProfile = interestsByProfile ?? _defaultInterests;

  final Map<String, List<String>> _interestsByProfile;

  List<ProfileLite> apply(List<ProfileLite> all, UserPrefs me) {
    if (all.isEmpty) {
      return const <ProfileLite>[];
    }
    final profile = me.profile;
    final List<ProfileLite> filtered =
        _filterByPreference(all, profile?.lookingFor);
    if (profile == null) {
      return List<ProfileLite>.unmodifiable(filtered);
    }
    final List<ProfileLite> prioritized =
        _prioritizeByInterests(filtered, profile.interests);
    return List<ProfileLite>.unmodifiable(prioritized);
  }

  List<ProfileLite> _filterByPreference(
    List<ProfileLite> source,
    String? lookingFor,
  ) {
    final String? normalizedPreference = _normalizePreference(lookingFor);
    if (normalizedPreference == null || normalizedPreference == 'everyone') {
      return List<ProfileLite>.from(source);
    }
    final String expectedGender =
        _preferenceToGender[normalizedPreference] ?? normalizedPreference;
    if (expectedGender == 'everyone') {
      return List<ProfileLite>.from(source);
    }
    final List<ProfileLite> filtered = <ProfileLite>[];
    for (final profile in source) {
      if (_matchesGender(profile.gender, expectedGender)) {
        filtered.add(profile);
      }
    }
    return filtered;
  }

  List<ProfileLite> _prioritizeByInterests(
    List<ProfileLite> source,
    List<String> interests,
  ) {
    if (source.isEmpty) {
      return const <ProfileLite>[];
    }
    if (interests.isEmpty) {
      return List<ProfileLite>.from(source);
    }
    final Set<String> normalizedInterests = interests
        .map(_normalizeInterest)
        .whereType<String>()
        .toSet();
    if (normalizedInterests.isEmpty) {
      return List<ProfileLite>.from(source);
    }

    final List<ProfileLite> withOverlap = <ProfileLite>[];
    final List<ProfileLite> withoutOverlap = <ProfileLite>[];
    for (final profile in source) {
      if (_hasSharedInterest(profile, normalizedInterests)) {
        withOverlap.add(profile);
      } else {
        withoutOverlap.add(profile);
      }
    }

    return <ProfileLite>[...withOverlap, ...withoutOverlap];
  }

  bool _hasSharedInterest(
    ProfileLite profile,
    Set<String> normalizedInterests,
  ) {
    final List<String>? profileInterests = _interestsByProfile[profile.id];
    if (profileInterests == null || profileInterests.isEmpty) {
      return false;
    }
    for (final String interest in profileInterests) {
      final String? normalized = _normalizeInterest(interest);
      if (normalized != null && normalizedInterests.contains(normalized)) {
        return true;
      }
    }
    return false;
  }

  bool _matchesGender(String rawGender, String expected) {
    final String? canonicalGender = _canonicalGender(rawGender);
    if (canonicalGender == null) {
      return false;
    }
    final String canonicalExpected =
        _canonicalGender(expected) ?? _normalizePreference(expected)!;
    return canonicalGender == canonicalExpected;
  }

  String? _canonicalGender(String? raw) {
    if (raw == null) {
      return null;
    }
    final String normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }
    return _genderAliases[normalized] ?? normalized;
  }

  String? _normalizePreference(String? raw) {
    if (raw == null) {
      return null;
    }
    final String normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  String? _normalizeInterest(String? raw) {
    if (raw == null) {
      return null;
    }
    final String normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static const Map<String, String> _genderAliases = <String, String>{
    'male': 'male',
    'man': 'male',
    'm': 'male',
    'female': 'female',
    'woman': 'female',
    'f': 'female',
    'non-binary': 'non-binary',
    'nonbinary': 'non-binary',
    'nb': 'non-binary',
  };

  static const Map<String, String> _preferenceToGender = <String, String>{
    'men': 'male',
    'man': 'male',
    'male': 'male',
    'women': 'female',
    'woman': 'female',
    'female': 'female',
  };

  static const Map<String, List<String>> _defaultInterests =
      <String, List<String>>{
    'u1': <String>['Hiking', 'Cycling', 'Travel'],
    'u2': <String>['Foodies', 'Design', 'Yoga'],
    'u3': <String>['Reading', 'Art', 'Coffee'],
    'u4': <String>['Fitness', 'Board games', 'Travel'],
    'u5': <String>['Cooking', 'Beach days', 'Karaoke'],
    'u6': <String>['Tech', 'Gardening', 'Sci-fi'],
    'u7': <String>['Photography', 'Road trips', 'Music'],
    'u8': <String>['Startups', 'Street food', 'Museums'],
  };
}






