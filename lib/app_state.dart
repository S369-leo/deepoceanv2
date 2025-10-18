import 'package:flutter/foundation.dart';
import 'models/profile.dart';

class AppState extends ChangeNotifier {
  final List<Profile> _liked = [];
  List<Profile> get liked => List.unmodifiable(_liked);

  void like(Profile p) {
    if (!_liked.any((x) => x.id == p.id)) {
      _liked.add(p);
      notifyListeners();
    }
  }
}
