import 'package:fitness_app/models/workout.dart';
import 'package:fitness_app/utility/in_memory_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutRepository {
  final _workouts = InMemoryStore<List<Workout>>([]);

  List<Workout> getWorkoutList() {
    return _workouts.value;
  }

  Workout? getWorkout(String id) {
    return _getWorkout(_workouts.value, id);
  }

  Future<List<Workout>> fetchWorkoutsList() async {
    return Future.value(_workouts.value);
  }

  Stream<List<Workout>> watchProductList() {
    return _workouts.stream;
  }

  Future<void> saveWorkout(List<Workout> workoutsRequest) async {
    final workouts = _workouts.value;

    for (var workout in workoutsRequest) {
      final index = workouts.indexWhere((w) => w.id == workout.id);
      if (index == -1) {
        workouts.add(workout);
      } else {
        workouts[index] = workout;
      }
    }

    _workouts.value = workouts;
  }

  static Workout? _getWorkout(List<Workout> workouts, String id) {
    try {
      return workouts.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
}

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});
