import 'package:fitness_app/features/exercise/data/exercise_repository.dart';
import 'package:fitness_app/features/exercise/providers/exercise_provider.dart';
import 'package:fitness_app/models/exercise.dart';
import 'package:fitness_app/models/user_profile.dart';
import 'package:fitness_app/utility/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseScreen extends ConsumerStatefulWidget {
  const ExerciseScreen({super.key});

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exercisesListStreamProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final filteredExercises = selectedCategory == null
        ? exercises
        : ref.watch(exerciseBycategoryProvider(selectedCategory));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          'Exercises',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      body: SafeArea(
        child: Column(
          spacing: 15,
          children: [
            SizedBox(height: 10),
            _buildCategoryList(),

            filteredExercises.value!.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 190),
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        Text(
                          'No exercises found',
                          style: Theme.of(context).textTheme.headlineMedium!
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: filteredExercises.when(
                      data: (exercises) {
                        return _buildExercisesList(exercises);
                      },
                      error: (error, stackTrace) =>
                          Center(child: Text('Error: $error')),
                      loading: () => Center(child: CircularProgressIndicator()),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final selectedCategory = ref.watch(selectedCategoryProvider);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: 40,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 5),
            children: Category.values.map((category) {
              final bool isSelected = selectedCategory == category;
              return _buildCategoryChip(
                label: _getCategoryName(category),
                icon: _getcategoryIcon(category),
                isSelected: isSelected,
                onTap: () {
                  if (isSelected) {
                    ref.read(selectedCategoryProvider.notifier).state = null;
                  } else {
                    ref.read(selectedCategoryProvider.notifier).state =
                        category;
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required IconData icon,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : AppColors.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          spacing: 6,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.primaryBlue,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primaryBlue,
                fontWeight: isSelected ? FontWeight.bold : null,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesList(List<Exercise> exercises) {
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
