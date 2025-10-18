import 'package:flutter/foundation.dart';

const String kProfilePlaceholderAsset = 'assets/images/placeholder.jpg';

@immutable
class ProfileLite {
  final String id;
  final String name;
  final int age;
  final String gender;
  final List<String> photos;
  final Map<String, String> promptAnswers;
  final bool verified;

  ProfileLite({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    List<String>? photos,
    String? imageAsset,
    Map<String, String>? promptAnswers,
    this.verified = false,
  })  : photos = List.unmodifiable(
          _resolvePhotos(photos, imageAsset),
        ),
        promptAnswers = Map.unmodifiable(promptAnswers ?? const {});

  static List<String> _resolvePhotos(
    List<String>? rawPhotos,
    String? imageAsset,
  ) {
    final List<String> resolved = <String>[];
    void addIfValid(String? value) {
      if (value == null || value.isEmpty || resolved.contains(value)) {
        return;
      }
      resolved.add(value);
    }

    addIfValid(imageAsset);
    if (rawPhotos != null) {
      for (final String photo in rawPhotos) {
        addIfValid(photo);
      }
    }
    if (resolved.isEmpty) {
      addIfValid(kProfilePlaceholderAsset);
    }
    return resolved;
  }

  String get imageAsset =>
      photos.isNotEmpty ? photos.first : kProfilePlaceholderAsset;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileLite &&
        other.id == id &&
        other.name == name &&
        other.age == age &&
        other.gender == gender &&
        listEquals(other.photos, photos) &&
        mapEquals(other.promptAnswers, promptAnswers) &&
        other.verified == verified;
  }

  @override
  int get hashCode {
    final Iterable<int> promptHashes = promptAnswers.entries
        .map((entry) => Object.hash(entry.key, entry.value));
    return Object.hash(
      id,
      name,
      age,
      gender,
      Object.hashAll(photos),
      Object.hashAll(promptHashes),
      verified,
    );
  }
}

enum ReactionType { like, laugh, fire }

@immutable
class Reaction {
  final String profileId;
  final String targetKey;
  final ReactionType type;
  final String? note;

  const Reaction({
    required this.profileId,
    required this.targetKey,
    required this.type,
    this.note,
  });

  Reaction copyWith({
    String? profileId,
    String? targetKey,
    ReactionType? type,
    String? note,
  }) {
    return Reaction(
      profileId: profileId ?? this.profileId,
      targetKey: targetKey ?? this.targetKey,
      type: type ?? this.type,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'profileId': profileId,
        'targetKey': targetKey,
        'type': type.name,
        if (note != null) 'note': note,
      };

  static Reaction? fromJson(dynamic json) {
    if (json is! Map) {
      return null;
    }
    late final Map<String, dynamic> map;
    try {
      map = Map<String, dynamic>.from(json);
    } catch (_) {
      return null;
    }
    final String? profileId = map['profileId'] as String?;
    final String? targetKey = map['targetKey'] as String?;
    if (profileId == null || targetKey == null) {
      return null;
    }
    final ReactionType type = _parseType(map);
    return Reaction(
      profileId: profileId,
      targetKey: targetKey,
      type: type,
      note: map['note'] as String?,
    );
  }

  static ReactionType _parseType(Map<String, dynamic> map) {
    final dynamic rawType = map['type'];
    if (rawType is String && rawType.isNotEmpty) {
      final String normalized = rawType.toLowerCase();
      for (final ReactionType candidate in ReactionType.values) {
        if (candidate.name == normalized) {
          return candidate;
        }
      }
    }
    final String? emoji = map['emoji'] as String?;
    if (emoji != null && emoji.isNotEmpty) {
      switch (emoji) {
        case '\u{2764}\u{FE0F}':
        case '\u{2764}':
          return ReactionType.like;
        case '\u{1F602}':
          return ReactionType.laugh;
        case '\u{1F525}':
          return ReactionType.fire;
      }
    }
    return ReactionType.like;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reaction &&
        other.profileId == profileId &&
        other.targetKey == targetKey &&
        other.type == type &&
        other.note == note;
  }

  @override
  int get hashCode => Object.hash(profileId, targetKey, type, note);
}