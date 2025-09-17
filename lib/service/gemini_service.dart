import 'dart:convert';

import 'package:fitness_app/data/exercises_dummy_data.dart';
import 'package:fitness_app/models/workout.dart';
import 'package:fitness_app/models/workout_request.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiService {
  static Gemini? _instance;

  static void init() {
    _instance = Gemini.instance;
  }

  static Gemini get instance {
    if (_instance == null) {
      throw Exception('Gemini not initialized');
    }

    return _instance!;
  }

  static Future<List<Workout>?> generateWorkout(WorkoutRequest request) async {
    try {
      final prompt = _buildWorkoutPrompt(request);

      final response = await instance.prompt(parts: [Part.text(prompt)]);

      if (response!.output != null) {
        return _workoutResponse(response.output!);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static String _buildWorkoutPrompt(WorkoutRequest request) {
    return '''
          Create a personalized workout plan from this $kExercises for a user of this following specifications:
           - Fitness level : ${request.level}
           - Fitness goal : ${request.goal}
           -  height : ${request.height}
           - weight: ${request.weight}
           - age: ${request.age}
           - available equipment: ${request.equipments}

      Please respond only with valid JSON array of workouts matching this dart model: $Workout
      Ensure the workout is safe, effective, and appropriate for the specified fitness level
      ''';
  }

  static List<Workout> _workoutResponse(String output) {
    final cleaned = output
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final dynamic decoded = jsonDecode(cleaned);

    if (decoded is List) {
      print('is List ${decoded.map((e) => Workout.fromMap(e)).toList()}');
      return decoded.map((e) => Workout.fromMap(e)).toList();
    } else if (decoded is Map<String, dynamic>) {
      print('is Map : ${Workout.fromMap(decoded)}');
      return [Workout.fromMap(decoded)];
    } else {
      throw Exception('Unexpected workout response format');
    }
  }
}
