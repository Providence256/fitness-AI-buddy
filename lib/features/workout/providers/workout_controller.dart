import 'package:fitness_app/features/authentication/data/auth_repository.dart';
import 'package:fitness_app/features/workout/data/workout_repository.dart';
import 'package:fitness_app/features/workout/providers/workout_state.dart';
import 'package:fitness_app/models/workout_request.dart';
import 'package:fitness_app/service/gemini_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutController extends StateNotifier<WorkoutState> {
  WorkoutController(this.workoutRepository, this.authRepository)
    : super(WorkoutState());

  final WorkoutRepository workoutRepository;
  final AuthRepository authRepository;

  Future<bool> generateAndSaveWorkout(WorkoutRequest request) async {
    final currentUser = authRepository.currentUser;

    if (currentUser == null) {
      state = state.copyWith(
        workouts: AsyncValue.error(
          'No authenticated user found',
          StackTrace.current,
        ),
      );
      return false;
    }

    state = state.copyWith(workouts: AsyncValue.loading());

    try {
      final generatedWorkouts = await GeminiService.generateWorkout(request);
      if (generatedWorkouts == null || generatedWorkouts.isEmpty) {
        state = state.copyWith(
          workouts: AsyncValue.error(
            'Failed to generate workout',
            StackTrace.current,
          ),
        );
        return false;
      }

      final workoutsToSave = generatedWorkouts.map((workout) {
        return workout.copyWith(id: workout.id, userId: currentUser.id);
      }).toList();

      await workoutRepository.saveWorkout(workoutsToSave);

      final existingWorkouts = state.workouts.value ?? [];
      final updatedWorkouts = [...workoutsToSave, ...existingWorkouts];

      state = state.copyWith(workouts: AsyncValue.data(updatedWorkouts));

      return true;
    } catch (e, stackTrace) {
      state = state.copyWith(workouts: AsyncValue.error(e, stackTrace));
      return false;
    }
  }
}

final workoutControllerProvider =
    StateNotifierProvider<WorkoutController, WorkoutState>((ref) {
      final workoutRepository = ref.watch(workoutRepositoryProvider);
      final authRepository = ref.watch(authRepositoryProvider);
      return WorkoutController(workoutRepository, authRepository);
    });
