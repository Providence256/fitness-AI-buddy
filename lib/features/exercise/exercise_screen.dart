import 'package:fitness_app/data/exercises_dummy_data.dart';
import 'package:fitness_app/models/exercise.dart';
import 'package:fitness_app/models/user_profile.dart';
import 'package:fitness_app/utility/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final exercises = kExercises;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Exercises'),
      ),
      body: SafeArea(
        child: Column(children: [Expanded(child: _buildExercisesList())]),
      ),
    );
  }

  Widget _buildExercisesList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercice = exercises[index];
        return _buildExerciseCard(exercice);
      },
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showExerciseDetails(exercise),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            spacing: 16,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getcategoryIcon(exercise.category),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Row(
                      spacing: 6,
                      children: [
                        _buildInfoChip(_getCategoryName(exercise.category)),
                        _buildInfoChip(_getLevelName(exercise.level)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showExerciseDetails(Exercise exercice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercice.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              children: [
                _buildInfoChip(_getCategoryName(exercice.category)),
                _buildInfoChip(_getLevelName(exercice.level)),
              ],
            ),
            SizedBox(height: 16),
            _buildDetailRow('Sets', '${exercice.sets}'),
            _buildDetailRow('Reps', '${exercice.reps}'),
            if (exercice.duration > 0)
              _buildDetailRow('Duration', '${exercice.duration} seconds'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 10),
            ),
            child: Text('Add to Workout'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  String _getLevelName(Level level) {
    switch (level) {
      case Level.beginner:
        return 'Beginner';
      case Level.intermediate:
        return 'Intermediate';
      case Level.advanced:
        return 'Advanced';
    }
  }

  IconData _getcategoryIcon(Category category) {
    switch (category) {
      case Category.chest:
        return Icons.fitness_center;
      case Category.back:
        return Icons.back_hand;
      case Category.shoulders:
        return Icons.accessibility_new;
      case Category.legs:
        return Icons.directions_walk;
      case Category.arms:
        return Icons.sports_martial_arts;
      case Category.biceps:
        return Icons.fitness_center;
      case Category.triceps:
        return Icons.sports_gymnastics;
    }
  }

  String _getCategoryName(Category category) {
    switch (category) {
      case Category.chest:
        return 'Chest';
      case Category.back:
        return 'Back';
      case Category.shoulders:
        return 'Shoulders';
      case Category.legs:
        return 'Legs';
      case Category.arms:
        return 'Arms';
      case Category.biceps:
        return 'Biceps';
      case Category.triceps:
        return 'Triceps';
    }
  }
}
