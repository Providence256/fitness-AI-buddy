import 'package:fitness_app/features/profile/data/profile_repository.dart';
import 'package:fitness_app/models/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileController extends StateNotifier<UserProfile?> {
  ProfileController(this.profileRepository) : super(null);

  final ProfileRepository profileRepository;

  Future<void> createUserProfile(UserProfile profile) async {}
}

final selectedLeverProvider = StateProvider<Level?>((ref) => null);

final selectedGoalProvider = StateProvider<Goal?>((ref) => null);
