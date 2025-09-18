import 'dart:async';
import 'package:fitness_app/models/exercise.dart';
import 'package:fitness_app/models/workout.dart';
import 'package:fitness_app/utility/constants/app_colors.dart';
import 'package:flutter/material.dart';

class StartWorkoutScreen extends StatefulWidget {
  final Workout workout;

  const StartWorkoutScreen({super.key, required this.workout});

  @override
  State<StartWorkoutScreen> createState() => _StartWorkoutScreenState();
}

class _StartWorkoutScreenState extends State<StartWorkoutScreen>
    with TickerProviderStateMixin {
  // Workout state
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  bool _isResting = false;
  bool _isWorkoutCompleted = false;

  // Timers
  Timer? _workoutTimer;
  Timer? _restTimer;
  int _workoutDuration = 0; // in seconds
  int _restDuration = 0; // in seconds
  static const int REST_TIME = 60; // 60 seconds rest between sets

  // Exercise completion tracking
  Map<String, List<bool>> _exerciseCompletionMap = {};

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeWorkout();
    _setupAnimations();
    _startWorkoutTimer();
  }

  void _initializeWorkout() {
    // Initialize completion map for all exercises and their sets
    for (var exercise in widget.workout.exercises) {
      _exerciseCompletionMap[exercise.id] = List.generate(
        exercise.sets,
        (index) => false,
      );
    }
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startWorkoutTimer() {
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _workoutDuration++;
      });
    });
  }

  void _startRestTimer() {
    setState(() {
      _isResting = true;
      _restDuration = REST_TIME;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _restDuration--;
      });

      if (_restDuration <= 0) {
        _skipRest();
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _restDuration = 0;
    });
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Exercise get _currentExercise =>
      widget.workout.exercises[_currentExerciseIndex];

  bool get _isCurrentSetCompleted {
    return _exerciseCompletionMap[_currentExercise.id]?[_currentSet - 1] ??
        false;
  }

  int get _completedSets {
    return _exerciseCompletionMap[_currentExercise.id]
            ?.where((completed) => completed)
            .length ??
        0;
  }

  double get _workoutProgress {
    int totalSets = widget.workout.exercises.fold(
      0,
      (sum, exercise) => sum + exercise.sets,
    );
    int completedSets = _exerciseCompletionMap.values.fold(
      0,
      (sum, sets) => sum + sets.where((completed) => completed).length,
    );
    return totalSets > 0 ? completedSets / totalSets : 0.0;
  }

  void _completeSet() {
    setState(() {
      _exerciseCompletionMap[_currentExercise.id]![_currentSet - 1] = true;
    });

    // Check if all sets for current exercise are completed
    if (_completedSets >= _currentExercise.sets) {
      _moveToNextExercise();
    } else if (_currentSet < _currentExercise.sets) {
      // Move to next set and start rest
      setState(() {
        _currentSet++;
      });
      _startRestTimer();
    }
  }

  void _moveToNextExercise() {
    if (_currentExerciseIndex < widget.workout.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSet = 1;
      });
      _startRestTimer();
    } else {
      _completeWorkout();
    }
  }

  void _moveToPreviousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
        _currentSet =
            _exerciseCompletionMap[_currentExercise.id]!.lastIndexWhere(
              (completed) => !completed,
            ) +
            1;
        if (_currentSet <= 0) _currentSet = _currentExercise.sets;
      });
      _skipRest();
    }
  }

  void _skipExercise() {
    _moveToNextExercise();
  }

  void _completeWorkout() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    setState(() {
      _isWorkoutCompleted = true;
    });
  }

  void _pauseWorkout() {
    if (_workoutTimer?.isActive == true) {
      _workoutTimer?.cancel();
    } else {
      _startWorkoutTimer();
    }
  }

  void _finishWorkout() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isWorkoutCompleted) {
      return _buildWorkoutCompleteScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.title),
        leading: IconButton(
          onPressed: _pauseWorkout,
          icon: Icon(
            _workoutTimer?.isActive == true ? Icons.pause : Icons.play_arrow,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showFinishWorkoutDialog(),
            icon: const Icon(Icons.stop),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildWorkoutProgress(),
              const SizedBox(height: 10),
              _buildWorkoutTimer(),
              const SizedBox(height: 10),
              Expanded(
                child: _isResting
                    ? _buildRestScreen()
                    : _buildCurrentExercise(),
              ),
              _buildWorkoutControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutProgress() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Exercise ${_currentExerciseIndex + 1} of ${widget.workout.exercises.length}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              '${(_workoutProgress * 100).round()}%',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _workoutProgress,
          backgroundColor: AppColors.textSecondary.withValues(alpha: 0.3),
          valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
        ),
      ],
    );
  }

  Widget _buildWorkoutTimer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTimerColumn(
            'Workout Time',
            _formatTime(_workoutDuration),
            Icons.timer,
            AppColors.primaryBlue,
          ),
          if (_isResting)
            _buildTimerColumn(
              'Rest Time',
              _formatTime(_restDuration),
              Icons.hourglass_bottom,
              Colors.orange,
              animated: true,
            ),
        ],
      ),
    );
  }

  Widget _buildTimerColumn(
    String label,
    String time,
    IconData icon,
    Color color, {
    bool animated = false,
  }) {
    Widget iconWidget = Icon(icon, color: color);

    if (animated) {
      iconWidget = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Icon(icon, color: color),
          );
        },
      );
    }

    return Column(
      children: [
        iconWidget,
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          time,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentExercise() {
    return Column(
      children: [
        // Exercise header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(Icons.fitness_center, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              Text(
                _currentExercise.name,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Set $_currentSet of ${_currentExercise.sets}',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Exercise details
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 15,
              children: [
                Text(
                  'Target',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTargetInfo(
                      'Reps',
                      '${_currentExercise.reps}',
                      Icons.repeat,
                    ),
                    if (_currentExercise.duration > 0)
                      _buildTargetInfo(
                        'Duration',
                        '${_currentExercise.duration}s',
                        Icons.timer,
                      ),
                  ],
                ),

                // Set completion status
                _buildSetCompletionStatus(),
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildSetCompletionStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_currentExercise.sets, (index) {
        final isCompleted = _exerciseCompletionMap[_currentExercise.id]![index];
        final isCurrent = index == _currentSet - 1;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : isCurrent
                ? AppColors.primaryBlue
                : Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: isCurrent
                ? Border.all(color: AppColors.primaryBlue, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: isCompleted || isCurrent ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWorkoutControls() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _currentExerciseIndex > 0
                  ? _moveToPreviousExercise
                  : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Previous'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isCurrentSetCompleted
                  ? _moveToNextExercise
                  : _completeSet,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCurrentSetCompleted
                    ? Colors.green
                    : AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_isCurrentSetCompleted ? 'Next Set' : 'Complete Set'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: _skipExercise,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestScreen() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
                child: const Icon(
                  Icons.hourglass_bottom,
                  color: Colors.orange,
                  size: 64,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Rest Time',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatTime(_restDuration),
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Take a break and prepare for the next set',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _skipRest,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Skip Rest'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCompleteScreen() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 80),
                const SizedBox(height: 24),
                Text(
                  'Workout Complete!',
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.workout.title,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall!.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Workout Summary',
                        style: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem(
                            'Duration',
                            _formatTime(_workoutDuration),
                          ),
                          _buildSummaryItem(
                            'Exercises',
                            '${widget.workout.exercises.length}',
                          ),
                          _buildSummaryItem(
                            'Sets',
                            '${_exerciseCompletionMap.values.fold(0, (sum, sets) => sum + sets.where((c) => c).length)}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _finishWorkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Finish Workout'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  void _showFinishWorkoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Finish Workout?'),
          content: const Text(
            'Are you sure you want to finish this workout early?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _completeWorkout();
              },
              child: const Text('Finish'),
            ),
          ],
        );
      },
    );
  }
}
