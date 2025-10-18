import 'dart:convert';

class UserProfile {
  UserProfile({
    required this.name,
    required this.age,
    required this.bio,
    this.gender,
    this.lookingFor,
    List<String> interests = const <String>[],
    List<String> photos = const <String>[],
  })  : interests = List.unmodifiable(interests),
        photos = List.unmodifiable(photos);

  final String name;
  final int age;
  final String bio;
  final String? gender;
  final String? lookingFor;
  final List<String> interests;
  final List<String> photos;

  factory UserProfile.empty() => UserProfile(
        name: '',
        age: 18,
        bio: '',
        gender: null,
        lookingFor: null,
        interests: const <String>[],
        photos: const <String>[],
      );

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: (json['name'] as String?)?.trim() ?? '',
      age: _parseAge(json['age']) ?? 18,
      bio: (json['bio'] as String?)?.trim() ?? '',
      gender: (json['gender'] as String?)?.trim(),
      lookingFor: (json['lookingFor'] as String?)?.trim(),
      interests: _stringList(json['interests']),
      photos: _stringList(json['photos']),
    );
  }

  UserProfile copyWith({
    String? name,
    int? age,
    String? bio,
    String? gender,
    String? lookingFor,
    List<String>? interests,
    List<String>? photos,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      lookingFor: lookingFor ?? this.lookingFor,
      interests: interests ?? this.interests,
      photos: photos ?? this.photos,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'age': age,
      'bio': bio,
      'gender': gender,
      'lookingFor': lookingFor,
      'interests': interests,
      'photos': photos,
    };
  }

  String encode() => jsonEncode(toJson());

  static int? _parseAge(dynamic raw) {
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

  static List<String> _stringList(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<String>()
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return <String>[raw.trim()];
    }
    return const <String>[];
  }
}
