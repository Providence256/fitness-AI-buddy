import 'package:fitness_app/models/exercise.dart';

class WorkoutRequest {
  final String level;
  final String goal;
  final List<Equipment> equipments;
  final double height;
  final double weight;
  final int age;

  WorkoutRequest({
    required this.level,
    required this.goal,
    required this.equipments,
    required this.height,
    required this.weight,
    required this.age,
  });
}
