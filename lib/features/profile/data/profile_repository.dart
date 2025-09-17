import 'package:fitness_app/models/user_profile.dart';
import 'package:fitness_app/utility/in_memory_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileRepository {
  final _userProfiles = InMemoryStore<List<UserProfile>>([]);

  Stream<List<UserProfile>> get profileStream => _userProfiles.stream;
  List<UserProfile> get profiles => _userProfiles.value;

  Future<void> createUserProfile(UserProfile user) async {
    await Future.delayed(Duration(milliseconds: 2000));
    final users = _userProfiles.value;
    final index = users.indexWhere((u) => u.id == user.id);

    if (index == -1) {
      users.add(user);
    } else {
      users[index] = user;
    }

    _userProfiles.value = users;
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    final users = _userProfiles.value;

    try {
      return users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});
