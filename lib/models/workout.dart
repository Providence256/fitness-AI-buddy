// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

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

  Workout copyWith({
    String? id,
    String? userId,
    String? title,
    List<Exercise>? exercises,
    DateTime? date,
  }) {
    return Workout(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      exercises: exercises ?? this.exercises,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'title': title,
      'exercises': exercises.map((x) => x.toMap()).toList(),
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      exercises: List<Exercise>.from(
        (map['exercises'] as List<dynamic>).map<Exercise>(
          (x) => Exercise.fromMap(x as Map<String, dynamic>),
        ),
      ),
      date: _parseDate(map['date']),
    );
  }

  // Helper method to parse date - add this to the Workout class
  static DateTime _parseDate(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      // Try parsing as ISO string first
      try {
        return DateTime.parse(value);
      } catch (e) {
        // If that fails, try parsing as milliseconds
        final milliseconds = int.tryParse(value);
        if (milliseconds != null) {
          return DateTime.fromMillisecondsSinceEpoch(milliseconds);
        }
      }
    }
    // Fallback to current time
    return DateTime.now();
  }

  String toJson() => json.encode(toMap());

  factory Workout.fromJson(String source) =>
      Workout.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Workout(id: $id, userId: $userId, title: $title, exercises: $exercises, date: $date)';
  }

  @override
  bool operator ==(covariant Workout other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.title == title &&
        listEquals(other.exercises, exercises) &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        exercises.hashCode ^
        date.hashCode;
  }
}
