// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:fitness_app/models/exercise.dart';

class Workout {
  final String id;
  final String title;
  final List<Exercise> exercises;
  final DateTime date;

  Workout({
    required this.id,
    required this.title,
    required this.exercises,
    required this.date,
  });

  Workout copyWith({
    String? id,
    String? title,
    List<Exercise>? exercises,
    DateTime? date,
  }) {
    return Workout(
      id: id ?? this.id,
      title: title ?? this.title,
      exercises: exercises ?? this.exercises,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'exercises': exercises.map((x) => x.toMap()).toList(),
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as String,
      title: map['title'] as String,
      exercises: List<Exercise>.from(
        (map['exercises'] as List<int>).map<Exercise>(
          (x) => Exercise.fromMap(x as Map<String, dynamic>),
        ),
      ),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Workout.fromJson(String source) =>
      Workout.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Workout(id: $id, title: $title, exercises: $exercises, date: $date)';
  }

  @override
  bool operator ==(covariant Workout other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        listEquals(other.exercises, exercises) &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ exercises.hashCode ^ date.hashCode;
  }
}
