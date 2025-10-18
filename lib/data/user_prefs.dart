import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class UserPrefs extends ChangeNotifier {
  static const String _storageKey = 'user_profile_v1';
  static const String _firstRunKey = 'user_first_run_v1';

  UserProfile? _profile;
  bool _hydrated = false;
  bool _isFirstRun = true;
  SharedPreferences? _prefs;

  UserProfile? get profile => _profile;
  bool get hasProfile => _profile != null;
  bool get isHydrated => _hydrated;
  bool get isFirstRun => _isFirstRun;

  Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    _isFirstRun = prefs.getBool(_firstRunKey) ?? true;

    final String? stored = prefs.getString(_storageKey);
    if (stored != null && stored.trim().isNotEmpty) {
      final UserProfile? parsed = _decode(stored);
      if (parsed != null) {
        _profile = parsed;
      }
    }
    _hydrated = true;
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    notifyListeners();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, profile.encode());
  }

  Future<void> setFirstRunFalse() async {
    if (!_isFirstRun) {
      return;
    }
    _isFirstRun = false;
    notifyListeners();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(_firstRunKey, false);
  }

  Future<void> clearProfile() async {
    _profile = null;
    notifyListeners();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  UserProfile? _decode(String stored) {
    try {
      final dynamic json = jsonDecode(stored);
      if (json is Map<String, dynamic>) {
        return UserProfile.fromJson(json);
      }
      if (json is Map) {
        return UserProfile.fromJson(
          json.map<String, dynamic>(
            (key, value) => MapEntry(key.toString(), value),
          ),
        );
      }
    } catch (_) {
      // Ignore malformed data; user can re-onboard.
    }
    return null;
  }
}
