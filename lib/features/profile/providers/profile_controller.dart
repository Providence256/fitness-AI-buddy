import 'package:fitness_app/features/authentication/data/auth_repository.dart';
import 'package:fitness_app/features/profile/data/profile_repository.dart';
import 'package:fitness_app/features/profile/providers/profile_state.dart';
import 'package:fitness_app/models/exercise.dart';
import 'package:fitness_app/models/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController(this.profileRepository, this.authRepository)
    : super(ProfileState());

  final ProfileRepository profileRepository;
  final AuthRepository authRepository;

  Future<bool> createUserProfile(
    String name,
    int age,
    double height,
    double weight,
    Goal goal,
    Level level,
    List<Equipment> equiments,
  ) async {
    final currentUser = authRepository.currentUser;

    if (currentUser == null) {
      state = state.copyWith(
        value: AsyncValue.error(
          'No Authenticated User found',
          StackTrace.current,
        ),
      );
    }
    state = state.copyWith(value: AsyncValue.loading());
    final profile = UserProfile(
      id: currentUser!.id,
      name: name,
      age: age,
      weight: weight,
      height: height,
      goal: goal,
      level: level,
      equipments: equiments,
      createdAt: DateTime.now(),
    );

    final value = await AsyncValue.guard(() async {
      await profileRepository.createUserProfile(profile);
    });

    state = state.copyWith(value: value);

    return value.hasError == false;
  }

  Future<void> loadUserProfile() async {
    final currentUser = authRepository.currentUser;
    if (currentUser == null) return;

    state = state.copyWith(value: AsyncValue.loading());

    final value = await AsyncValue.guard(() async {
      await profileRepository.getUserProfile(currentUser.id);
    });

    state = state.copyWith(value: value);
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
      final profileRepository = ref.watch(profileRepositoryProvider);
      final authRepository = ref.watch(authRepositoryProvider);
      return ProfileController(profileRepository, authRepository);
    });

final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  final profileRepository = ref.watch(profileRepositoryProvider);

  final currentUser = authRepository.currentUser;
  if (currentUser == null) return null;
  return await profileRepository.getUserProfile(currentUser.id);
});

final selectedLeverProvider = StateProvider<Level?>((ref) => null);

final selectedGoalProvider = StateProvider<Goal?>((ref) => null);

final selectedEquipementProvider = StateProvider<List<Equipment>>((ref) => []);
