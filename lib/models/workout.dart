import 'package:fitness_app/models/exercise.dart';

class Workout {
  final String id;
  final String userId;
  final String title;
  final List<Exercise> exercises;
  final DateTime date;

  Workout({
    required this.id,
    required this.userId,
    required this.title,
    required this.exercises,
    required this.date,
  });
}
