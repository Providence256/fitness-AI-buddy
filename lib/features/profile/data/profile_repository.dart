import 'package:fitness_app/models/user_profile.dart';
import 'package:fitness_app/utility/in_memory_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileRepository {
  final _userProfiles = InMemoryStore<List<UserProfile>>([]);

  Future<void> createUserProfile(UserProfile user) async {
    final users = _userProfiles.value;
    final index = users.indexWhere((u) => u.id == user.id);

    if (index != -1) {
      users.add(user);
    } else {
      users[index] = user;
    }

    _userProfiles.value = users;
  }
}

final profileProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});
