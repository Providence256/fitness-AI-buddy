import 'dart:async';

import 'package:fitness_app/data/workout_dummy_data.dart';
import 'package:fitness_app/features/workout/providers/workout_controller.dart';
import 'package:fitness_app/models/exercise.dart';
import 'package:fitness_app/models/workout.dart';
import 'package:fitness_app/utility/constants/app_colors.dart';
import 'package:fitness_app/widgets/error_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with TickerProviderStateMixin {
  bool _isWorkoutActive = false;
  Workout? _currentWorkout;
  int _currentExerciseIndex = 0;
  Timer? _workoutTimer;
  Timer? _restTimer;
  int _workoutDuration = 0;
  int _restDuration = 0;
  bool _isResting = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    _pulseController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    super.initState();
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  final workoutData = WorkoutDummyData().workoutTemplates;
  @override
  Widget build(BuildContext context) {
    return _buildWorkoutHome();
  }

  Widget _buildWorkoutHome() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Workouts'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add))],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 32,
            children: [
              _buildQuickStartSection(),
              _buildWorkoutTemplates(),
              _buildRecentWorkouts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStartSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(29),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8,
            children: [
              Icon(Icons.flash_on, color: Colors.white, size: 24),
              Text(
                'Quick Start',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Jump into a workout right away',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryBlue,
              ),
              child: Text('Start Empty Workout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutTemplates() {
    return Consumer(
      builder: (context, ref, child) {
        final workoutController = ref.read(workoutControllerProvider);
        return workoutController.workouts.when(
          data: (workouts) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workout Templates',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    return _buildWorkoutCard(workouts[index]);
                  },
                ),
              ],
            );
          },
          error: (error, stackTrace) => ErrorStateWidget(error: error),
          loading: () => Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _startWorkout(workout),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workout.title,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.play_arrow,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '${workout.exercises.length} exercises',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: workout.exercises.take(3).map((exercise) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      exercise.name,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (workout.exercises.length > 3)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    '+${workout.exercises.length - 3} more',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentWorkouts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Workouts',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.copyWith(color: AppColors.primaryBlue),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildRecentWorkoutItem(
          'Push Day - chest & Triceps',
          'Yesterday . 45 mins',
          Icons.fitness_center,
        ),
      ],
    );
  }

  Widget _buildRecentWorkoutItem(String title, String subTitle, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: AppColors.primaryBlue),
        ),
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subTitle),
        trailing: IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
      ),
    );
  }

  Widget _buildActiveWorkout(Workout workout) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.title),
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.pause)),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.stop))],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              _buildWorkoutProgress(),
              SizedBox(height: 24),
              _buildworkoutTimer(),
              SizedBox(height: 24),
              Expanded(
                child: _isResting
                    ? _buildRestScreen()
                    : _buildCurrentExercise(workoutData[0].exercises[0]),
              ),
              _buildWorkoutControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutProgress() {
    final progress = (0 + 1) / workoutData[0].exercises.length;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Exercise ${0 + 1} of ${workoutData[0].exercises.length} of ${workoutData[0].exercises.length}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.textSecondary.withValues(alpha: 0.3),
          valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
        ),
      ],
    );
  }

  Widget _buildworkoutTimer() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Icon(Icons.timer, color: AppColors.primaryBlue),
              SizedBox(height: 4),
              Text(
                'Workout Time',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '$_workoutDuration',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          if (_isResting) ...[
            Column(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Icon(Icons.hourglass_bottom, color: Colors.orange),
                    );
                  },
                ),
                SizedBox(height: 4),
                Text('Rest Time', style: Theme.of(context).textTheme.bodySmall),
                Text(
                  '$_restDuration',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium!.copyWith(color: Colors.white),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentExercise(Exercise exercice) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(Icons.fitness_center, color: Colors.white, size: 48),
              Text(
                exercice.name,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Set 2 of ${exercice.sets}',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),

        Expanded(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Target',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    _buildTargetInfo('Reps', '${exercice.reps}', Icons.repeat),
                    if (exercice.duration > 0)
                      _buildTargetInfo(
                        'Duration',
                        '${exercice.duration}s',
                        Icons.timer,
                      ),
                  ],
                ),
                Text(
                  'Ready when you are!',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Tap "Compelete Set" when finished',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryBlue),
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildWorkoutControls() {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Row(
        spacing: 16,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Previous'),
            ),
          ),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {},
              child: Text('Complete Set'),
            ),
          ),
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestScreen() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Icon(
                  Icons.hourglass_bottom,
                  color: Colors.orange,
                  size: 48,
                ),
              );
            },
          ),
          SizedBox(height: 24),
          Text(
            'Rest Time',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(color: Colors.orange),
          ),
          SizedBox(height: 8),
          Text(
            '$_restDuration',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              fontSize: 36,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Take a break and prepare for next set',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              side: BorderSide(color: Colors.orange),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text('Skip Rest'),
          ),
        ],
      ),
    );
  }

  void _startWorkout(Workout workout) {
    if (workout.exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Add Exercises to start your workout'),
          action: SnackBarAction(label: 'Add Exercises', onPressed: () {}),
        ),
      );
    }
  }
}
