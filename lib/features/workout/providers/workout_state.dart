// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitness_app/models/workout.dart';

class WorkoutState {
  WorkoutState({
    this.workouts = const AsyncValue.data([]),
    this.currentWorkout = const AsyncValue.data(null),
  });
  final AsyncValue<List<Workout>> workouts;
  final AsyncValue<Workout?> currentWorkout;

  WorkoutState copyWith({
    AsyncValue<List<Workout>>? workouts,
    AsyncValue<Workout?>? currentWorkout,
  }) {
    return WorkoutState(
      workouts: workouts ?? this.workouts,
      currentWorkout: currentWorkout ?? this.currentWorkout,
    );
  }
}
