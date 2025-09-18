import 'dart:convert';

import 'package:fitness_app/data/exercises_dummy_data.dart';
import 'package:fitness_app/features/workout/providers/workout_controller.dart';
import 'package:fitness_app/models/workout.dart';
import 'package:fitness_app/models/workout_request.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeminiService {
  static Gemini? _instance;

  static void init({required String apiKey}) {
    _instance = Gemini.init(apiKey: apiKey);
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
        Please respond ONLY with valid JSON array of workouts.  
      Each workout object must have:
      Please respond only with valid JSON array of workouts matching this dart model: 
      - Workout (
              id as String;
               userId as String;
               title;
               List<Exercise> exercises;
              DateTime date;
          )   
      Ensure the workout is safe, effective, and appropriate for the specified fitness level
      ''';
  }

  static Future<bool> generateAndSaveWorkout(
    WorkoutRequest request,
    WidgetRef ref,
  ) async {
    final workoutController = ref.read(workoutControllerProvider.notifier);
    return await workoutController.generateAndSaveWorkout(request);
  }

  static List<Workout> _workoutResponse(String output) {
    final cleaned = output
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final dynamic decoded = jsonDecode(cleaned);

    if (decoded is List) {
      return decoded.map((e) => Workout.fromMap(e)).toList();
    } else if (decoded is Map<String, dynamic>) {
      return [Workout.fromMap(decoded)];
    } else {
      throw Exception('Unexpected workout response format');
    }
  }
}
