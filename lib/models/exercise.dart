import 'package:fitness_app/models/user_profile.dart';

class Exercise {
  final String id;
  final String name;
  final Category category;
  final int sets;
  final int reps;
  final int duration;
  final Level level;
  final String? imageUrl;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.sets,
    required this.reps,
    required this.duration,
    required this.level,
    this.imageUrl,
  });
}

enum Category { chest, back, shoulders, legs, arms, biceps, triceps }
