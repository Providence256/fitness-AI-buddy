import 'package:fitness_app/models/stats.dart';

class UserProfile {
  final String id;
  final String name;
  final int age;
  final double weight;
  final double height;
  final Goal goal;
  final Level level;
  final Stats stats;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.goal,
    required this.level,
    required this.stats,
    required this.createdAt,
  });
}

enum Goal { gainMuscle, fatLoss, endurance }

enum Level { beginner, intermediate, advanced }
