import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_lite.dart';

class LikesRepository extends ChangeNotifier {
  static const String _storageKey = 'likes_v1';
  // ignore: unused_field
  static const String _blockedKey = 'blocked';

  final List<ProfileLite> _likes = <ProfileLite>[];
  final Set<String> _blockedIds = <String>{};
  final Set<String> _likeIds = <String>{};
  final Map<String, List<Reaction>> _reactionsByProfileId =
      <String, List<Reaction>>{};
  late final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<ProfileLite> get likes => List.unmodifiable(_likes);
  List<String> get blockedIds => List.unmodifiable(_blockedIds);

  Map<String, List<Reaction>> get reactionsByProfileId =>
      _reactionsByProfileId.map(
        (key, value) => MapEntry(key, List.unmodifiable(value)),
      );

  List<Reaction> reactionsFor(String profileId) =>
      List.unmodifiable(_reactionsByProfileId[profileId] ?? const <Reaction>[]);

  Future<bool> hydrate() async {
    final prefs = await _prefs;
    final String? stored = prefs.getString(_storageKey);

    final List<ProfileLite> hydratedLikes = <ProfileLite>[];
    final Set<String> hydratedBlocked = <String>{};
    final Map<String, List<Reaction>> hydratedReactions =
        <String, List<Reaction>>{};

    if (stored != null && stored.trim().isNotEmpty) {
      dynamic decoded;
      try {
        decoded = jsonDecode(stored);
      } catch (_) {
        decoded = null;
      }

      if (decoded is List) {
        _parseLikesList(decoded, hydratedLikes);
      } else if (decoded is Map) {
        final dynamic likesJson = decoded['likes'];
        if (likesJson is List) {
          _parseLikesList(likesJson, hydratedLikes);
        }

        final dynamic reactionsJson = decoded['reactions'];
        if (reactionsJson is Map) {
          reactionsJson.forEach((key, value) {
            String? profileId;
            if (key is String) {
              profileId = key;
            } else if (key != null) {
              profileId = key.toString();
            }
            if (profileId == null || value is! List) {
              return;
            }
            final List<Reaction> parsed = <Reaction>[];
            for (final dynamic reactionJson in value) {
              final Reaction? reaction = Reaction.fromJson(reactionJson);
              if (reaction != null) {
                parsed.add(reaction);
              }
            }
            if (parsed.isNotEmpty) {
              hydratedReactions[profileId] = parsed;
            }
          });
        }
      }
    }

    final bool likesChanged = !listEquals(_likes, hydratedLikes);
    final bool reactionsChanged =
        !_areReactionsEqual(_reactionsByProfileId, hydratedReactions);

    _likes
      ..clear()
      ..addAll(hydratedLikes);
    _likeIds
      ..clear()
      ..addAll(hydratedLikes.map((profile) => profile.id));
    _reactionsByProfileId
      ..clear()
      ..addEntries(
        hydratedReactions.entries.map(
          (entry) => MapEntry(
            entry.key,
            List<Reaction>.from(entry.value),
          ),
        ),
      );
    _blockedIds
      ..clear()
      ..addAll(hydratedBlocked);

    if (likesChanged || reactionsChanged) {
      notifyListeners();
    }

    return hydratedLikes.isNotEmpty;
  }

  bool addLike(ProfileLite profile) {
    if (isBlocked(profile.id)) {
      return false;
    }
    final bool isNew = _likeIds.add(profile.id);
    if (!isNew) {
      return false;
    }
    _likes.add(profile);
    notifyListeners();
    unawaited(_save());
    return true;
  }

  void addReaction(Reaction reaction) {
    final List<Reaction> reactions = _reactionsByProfileId.putIfAbsent(
        reaction.profileId, () => <Reaction>[]);
    reactions.add(reaction);
    notifyListeners();
    unawaited(_save());
  }

  bool removeLike(String id) {
    final bool removed = _removeLikeInternal(id);
    if (!removed) {
      return false;
    }
    notifyListeners();
    unawaited(_save());
    return true;
  }

  bool _removeLikeInternal(String id) {
    final bool removedId = _likeIds.remove(id);
    if (!removedId) {
      return false;
    }
    _likes.removeWhere((p) => p.id == id);
    _reactionsByProfileId.remove(id);
    notifyListeners();
    unawaited(_save());
    return true;
  }

  bool clear() {
    if (_likes.isEmpty && _reactionsByProfileId.isEmpty) {
      return false;
    }
    _likes.clear();
    _likeIds.clear();
    _reactionsByProfileId.clear();
    notifyListeners();
    unawaited(_save());
    return true;
  }

  Future<void> _save() async {
    final prefs = await _prefs;
    final List<Map<String, dynamic>> likesPayload = _likes
        .map((profile) => <String, dynamic>{
              'id': profile.id,
              'name': profile.name,
              'age': profile.age,
              'gender': profile.gender,
              'photos': profile.photos,
              'promptAnswers': profile.promptAnswers,
              'verified': profile.verified,
              'imageAsset': profile.imageAsset,
            })
        .toList(growable: false);

    final Map<String, List<Map<String, dynamic>>> reactionsPayload =
        _reactionsByProfileId.map(
      (key, value) => MapEntry(
        key,
        value.map((reaction) => reaction.toJson()).toList(growable: false),
      ),
    );

    final Map<String, dynamic> payload = <String, dynamic>{
      'likes': likesPayload,
      if (reactionsPayload.isNotEmpty) 'reactions': reactionsPayload,
    };

    await prefs.setString(_storageKey, jsonEncode(payload));
  }

  void _parseLikesList(List<dynamic> source, List<ProfileLite> target) {
    final Set<String> ids = <String>{};
    for (final dynamic item in source) {
      final ProfileLite? profile = _profileFromJson(item);
      if (profile == null) {
        continue;
      }
      if (ids.add(profile.id)) {
        target.add(profile);
      }
    }
  }

  ProfileLite? _profileFromJson(dynamic json) {
    if (json is! Map) {
      return null;
    }

    late final Map<String, dynamic> map;
    try {
      map = Map<String, dynamic>.from(json);
    } catch (_) {
      return null;
    }

    final String? id = map['id'] as String?;
    final String? name = map['name'] as String?;
    final String? gender = map['gender'] as String?;
    final String? imageAsset =
        (map['imageAsset'] ?? map['localImagePath']) as String?;
    final int? age = _parseAge(map['age']);

    if (id == null || id.isEmpty) {
      return null;
    }
    if (name == null || name.isEmpty) {
      return null;
    }
    if (gender == null || gender.isEmpty) {
      return null;
    }
    if (age == null) {
      return null;
    }

    final List<String> photos = <String>[];
    void addPhoto(String? value) {
      if (value == null || value.isEmpty || photos.contains(value)) {
        return;
      }
      photos.add(value);
    }

    final dynamic photosJson = map['photos'];
    if (photosJson is List) {
      for (final dynamic item in photosJson) {
        if (item is String) {
          addPhoto(item);
        }
      }
    } else if (photosJson is String) {
      addPhoto(photosJson);
    }

    addPhoto(imageAsset);
    if (photos.isEmpty) {
      addPhoto(kProfilePlaceholderAsset);
    }

    final Map<String, String> promptAnswers = <String, String>{};
    final dynamic promptsJson = map['promptAnswers'];
    if (promptsJson is Map) {
      promptsJson.forEach((key, value) {
        if (key is String &&
            key.isNotEmpty &&
            value is String &&
            value.isNotEmpty) {
          promptAnswers[key] = value;
        }
      });
    }

    final bool verified = _parseVerified(map['verified']);

    return ProfileLite(
      id: id,
      name: name,
      age: age,
      gender: gender,
      photos: photos,
      promptAnswers: promptAnswers,
      verified: verified,
    );
  }

  int? _parseAge(dynamic raw) {
    if (raw is int) {
      return raw;
    }
    if (raw is num) {
      return raw.toInt();
    }
    if (raw is String) {
      return int.tryParse(raw);
    }
    return null;
  }

  bool _parseVerified(dynamic raw) {
    if (raw is bool) {
      return raw;
    }
    if (raw is num) {
      return raw != 0;
    }
    if (raw is String) {
      return raw.toLowerCase() == 'true';
    }
    return false;
  }

  bool isBlocked(String id) => _blockedIds.contains(id);

  Future<bool> blockProfile(String id) async {
    final bool added = _blockedIds.add(id);
    final bool removedLike = _removeLikeInternal(id);
    if (!added && !removedLike) {
      return false;
    }
    notifyListeners();
    await _save();
    return true;
  }

  Future<bool> unblockProfile(String id) async {
    final bool removed = _blockedIds.remove(id);
    if (!removed) {
      return false;
    }
    notifyListeners();
    await _save();
    return true;
  }

  static bool _areReactionsEqual(
    Map<String, List<Reaction>> a,
    Map<String, List<Reaction>> b,
  ) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (final MapEntry<String, List<Reaction>> entry in a.entries) {
      final List<Reaction>? otherList = b[entry.key];
      if (otherList == null || !listEquals(entry.value, otherList)) {
        return false;
      }
    }
    return true;
  }

  // ignore: unused_element
  static bool _setEquals(Set<String> a, Set<String> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (final String value in a) {
      if (!b.contains(value)) {
        return false;
      }
    }
    return true;
  }
}
