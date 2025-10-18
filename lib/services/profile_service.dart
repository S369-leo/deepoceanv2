import 'dart:async';
import '../models/profile.dart';

/// Temporary in-memory data so we can run the app without Firebase.
class ProfileService {
  final List<Profile> _all = [
    Profile(
      id: '1',
      name: 'Anna Rivera',
      age: 26,
      gender: 'Female',
      imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
    ),
    Profile(
      id: '2',
      name: 'Marcus Lee',
      age: 29,
      gender: 'Male',
      imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800',
    ),
    Profile(
      id: '3',
      name: 'Chloe Nguyen',
      age: 31,
      gender: 'Female',
      imageUrl: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=800',
    ),
    Profile(
      id: '4',
      name: 'Sam Okoye',
      age: 24,
      gender: 'Male',
      imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
    ),
  ];

  /// In a real app this would be Firestore stream; here we just emit once.
  Stream<List<Profile>> getDiscoverProfiles() async* {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    yield List<Profile>.from(_all);
  }
}
