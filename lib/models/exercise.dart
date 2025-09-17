// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

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
    this.equipments = const [],
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
  final List<Equipment> equipments;
  final String? imageUrl;

  Exercise copyWith({
    String? id,
    String? name,
    Category? category,
    int? sets,
    int? reps,
    int? duration,
    Level? level,
    Goal? goal,
    List<Equipment>? equipments,
    String? imageUrl,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      duration: duration ?? this.duration,
      level: level ?? this.level,
      goal: goal ?? this.goal,
      equipments: equipments ?? this.equipments,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'category': category.name,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'level': level.name,
      'goal': goal.name,
      'equipments': equipments.map((x) => x.name).toList(),
      'imageUrl': imageUrl,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      category: Category.values.firstWhere((e) => e.name == map['category']),
      sets: map['sets'] as int,
      reps: map['reps'] as int,
      duration: map['duration'] as int,
      level: Level.values.firstWhere((e) => e.name == map['level']),
      goal: Goal.values.firstWhere((e) => e.name == map['goal']),
      equipments: [],
      imageUrl: map['imageUrl'] != null ? map['imageUrl'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Exercise.fromJson(String source) =>
      Exercise.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, category: $category, sets: $sets, reps: $reps, duration: $duration, level: $level, goal: $goal, equipments: $equipments, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(covariant Exercise other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.category == category &&
        other.sets == sets &&
        other.reps == reps &&
        other.duration == duration &&
        other.level == level &&
        other.goal == goal &&
        listEquals(other.equipments, equipments) &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        category.hashCode ^
        sets.hashCode ^
        reps.hashCode ^
        duration.hashCode ^
        level.hashCode ^
        goal.hashCode ^
        equipments.hashCode ^
        imageUrl.hashCode;
  }
}

enum Category { chest, back, shoulders, legs, arms, biceps, triceps }

enum Equipment {
  dumbbells,
  barbell,
  kettlebell,
  resistanceBands,
  pullUpBar,
  benchPress,
  treadmill,
  bicycle,
  yogaMat,
  jumpRope,
  medicineBall,
  foamRoller,
  none,
}
