import 'package:fitness_app/models/user_profile.dart';

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.sets,
    required this.reps,
    required this.duration,
    required this.level,
    required this.goal,
    this.imageUrl,
  });

  final String id;
  final String name;
  final Category category;
  final int sets;
  final int reps;
  final int duration;
  final Level level;
  final Goal goal;
  final String? imageUrl;
}

enum Category { chest, back, shoulders, legs, arms, biceps, triceps }
