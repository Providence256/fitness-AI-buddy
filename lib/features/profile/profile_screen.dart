import 'package:fitness_app/common/primary_button.dart';
import 'package:fitness_app/features/profile/providers/profile_controller.dart';
import 'package:fitness_app/models/exercise.dart';
import 'package:fitness_app/models/user_profile.dart';
import 'package:fitness_app/models/workout_request.dart';
import 'package:fitness_app/service/gemini_service.dart';
import 'package:fitness_app/utility/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String get name => _nameController.text;
  String get age => _ageController.text;
  String get height => _heightController.text;
  String get weight => _weightController.text;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previous() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return _formKey.currentState!.validate();
      case 2:
        final selectedGoal = ref.read(selectedGoalProvider);
        if (selectedGoal == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select a fitness Goal')),
          );
          return false;
        }
        return true;
      case 3:
        final selectedLevel = ref.read(selectedLeverProvider);
        if (selectedLevel == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select a fitness level')),
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _submit() async {
    if (!_validateCurrentStep()) return;
    final selectedGoal = ref.watch(selectedGoalProvider);
    final selectedLevel = ref.watch(selectedLeverProvider);
    final selectedEquipment = ref.watch(selectedEquipementProvider);

    final int parseAge = int.tryParse(age) ?? 0;
    final double parsedHeight = double.tryParse(height) ?? 0;
    final double parsedWeight = double.tryParse(weight) ?? 0;

    final controller = ref.read(profileControllerProvider.notifier);

    final success = await controller.createUserProfile(
      name.trim(),
      parseAge,
      parsedHeight,
      parsedWeight,
      selectedGoal!,
      selectedLevel!,
      selectedEquipment,
    );

    final workoutRequest = WorkoutRequest(
      level: selectedLevel.name,
      goal: selectedGoal.name,
      equipments: selectedEquipment,
      height: parsedHeight,
      weight: parsedWeight,
      age: parseAge,
    );
    if (success) {
      await GeminiService.generateWorkout(workoutRequest);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Profile created successfully')));
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      if (mounted) {
        final error = ref.read(profileControllerProvider).value.error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile was not created successfully, Error: $error',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Your Profile')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            _buildProgressIndicator(),

            Expanded(
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: (value) {},
                children: [
                  _buildWelcomStep(),
                  _buildPersonalInfoStep(),
                  _buildGoalStep(),
                  _buildLevelAndEquipmentStep(),
                ],
              ),
            ),

            // Navigation Buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        spacing: 12,
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              bool isActive = index <= _currentStep;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
              );
            }),
          ),
          Text(
            'Step ${_currentStep + 1} of $_totalSteps',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomStep() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(Icons.person_add, size: 64, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Let\'s Get Started',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge!.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Tell us about yourself to create a personalized fitness experience tailored just for you',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                Text(
                  'this will only take a few minutes',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'help us get to know you better',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 30),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'name is required';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            // Age and Weight
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      prefixIcon: Icon(Icons.cake_outlined),
                      suffixText: 'Years',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'age is required';
                      }
                      return null;
                    },
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Weight',
                      prefixIcon: Icon(Icons.monitor_weight_outlined),
                      suffixText: 'Kg',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'weight is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),
            // height field
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Height',
                prefixIcon: Icon(Icons.height_outlined),
                suffixText: 'Cm',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Height is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final selectedGoal = ref.watch(selectedGoalProvider);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What\'s your Goal',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'Choose your primary fitness objective',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 30),
              ...Goal.values.map((goal) {
                final bool isSelected = selectedGoal == goal;
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      ref.read(selectedGoalProvider.notifier).state = goal;
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.textSecondary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? AppColors.primaryBlue.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                      child: Row(
                        spacing: 5,
                        children: [
                          Icon(
                            _getGoalIcon(goal),
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.textSecondary,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGoalTitle(goal),
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primaryBlue
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  _getGoalDescription(goal),
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primaryBlue
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLevelAndEquipmentStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final selectedLevel = ref.watch(selectedLeverProvider);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fitness Level',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'What\'s your current fitness level?',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: Level.values.map((level) {
                  final bool isSelected = selectedLevel == level;

                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () {
                          ref.read(selectedLeverProvider.notifier).state =
                              level;
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : AppColors.textSecondary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected
                                ? AppColors.primaryBlue.withValues(alpha: 0.3)
                                : Colors.transparent,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _getLevelIcon(level),
                                color: _getLevelColor(level),
                              ),
                              Text(
                                _getLevelTitle(level),
                                style: Theme.of(context).textTheme.labelLarge!
                                    .copyWith(
                                      color: isSelected
                                          ? AppColors.primaryBlue
                                          : AppColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 40),
              _buildEquipmentSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEquipmentSection() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final selectedEquipment = ref.watch(selectedEquipementProvider);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Equipment',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Select all equipment you have access to (optional)',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 15),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Equipment.values.map((equipment) {
                final bool isSelected = selectedEquipment.contains(equipment);
                return InkWell(
                  onTap: () {
                    final equipmementNotifier = ref.read(
                      selectedEquipementProvider.notifier,
                    );
                    if (equipment == Equipment.none) {
                      equipmementNotifier.state = [Equipment.none];
                      return;
                    }
                    if (isSelected) {
                      final updated = selectedEquipment
                          .where((e) => e != equipment)
                          .toList();
                      if (updated.isEmpty) {
                        updated.add(Equipment.none);
                      } else {
                        updated.remove(Equipment.none);
                      }

                      equipmementNotifier.state = updated;
                    } else {
                      final updated = [
                        ...selectedEquipment.where((e) => e != Equipment.none),
                        equipment,
                      ];
                      equipmementNotifier.state = updated;
                    }
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.textSecondary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      color: isSelected
                          ? AppColors.primaryBlue.withValues(alpha: 0.1)
                          : Colors.transparent,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Icon(
                          _getEquipmentIcon(equipment),
                          size: 20,
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.textSecondary,
                        ),
                        Text(
                          _getEquipmentTitle(equipment),
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (isSelected) ...[
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.primaryBlue,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previous,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (_currentStep > 0) SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final state = ref.watch(profileControllerProvider);
                final isLastStep = _currentStep == _totalSteps - 1;
                return PrimaryButton(
                  text: isLastStep ? 'Create Profile' : 'Next',
                  isLoading: isLastStep ? state.isLoading : false,
                  onPressed: (isLastStep && state.isLoading)
                      ? null
                      : isLastStep
                      ? _submit
                      : _nextStep,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGoalIcon(Goal goal) {
    switch (goal) {
      case Goal.gainMuscle:
        return Icons.fitness_center;
      case Goal.fatLoss:
        return Icons.local_fire_department;
      case Goal.endurance:
        return Icons.directions_run;
    }
  }

  String _getGoalTitle(Goal goal) {
    switch (goal) {
      case Goal.gainMuscle:
        return 'Gain Muscle';
      case Goal.fatLoss:
        return 'Fat Loss';
      case Goal.endurance:
        return 'Build Endurance';
    }
  }

  String _getGoalDescription(Goal goal) {
    switch (goal) {
      case Goal.gainMuscle:
        return 'Build strength and muscle mass';
      case Goal.fatLoss:
        return 'Burn fat and get lean';
      case Goal.endurance:
        return 'Improve Cardiovascular fitness';
    }
  }

  IconData _getLevelIcon(Level level) {
    switch (level) {
      case Level.beginner:
        return Icons.sentiment_satisfied_outlined;
      case Level.intermediate:
        return Icons.trending_up;
      case Level.advanced:
        return Icons.emoji_events;
    }
  }

  String _getLevelTitle(Level level) {
    switch (level) {
      case Level.beginner:
        return 'Beginner';
      case Level.intermediate:
        return 'Intermediate';
      case Level.advanced:
        return 'Advanced';
    }
  }

  Color _getLevelColor(Level level) {
    switch (level) {
      case Level.beginner:
        return Colors.red;
      case Level.intermediate:
        return Colors.orange;
      case Level.advanced:
        return Colors.green;
    }
  }

  IconData _getEquipmentIcon(Equipment equipment) {
    switch (equipment) {
      case Equipment.dumbbells:
        return Icons.fitness_center;
      case Equipment.barbell:
        return Icons.line_weight;
      case Equipment.kettlebell:
        return Icons.sports_gymnastics;
      case Equipment.resistanceBands:
        return Icons.link;
      case Equipment.pullUpBar:
        return Icons.horizontal_rule;
      case Equipment.benchPress:
        return Icons.weekend;
      case Equipment.treadmill:
        return Icons.directions_run;
      case Equipment.bicycle:
        return Icons.directions_bike;
      case Equipment.yogaMat:
        return Icons.sports_martial_arts;
      case Equipment.jumpRope:
        return Icons.loop;
      case Equipment.medicineBall:
        return Icons.sports_volleyball;
      case Equipment.foamRoller:
        return Icons.roller_skating;
      case Equipment.none:
        return Icons.not_interested;
    }
  }

  String _getEquipmentTitle(Equipment equipment) {
    switch (equipment) {
      case Equipment.dumbbells:
        return 'Dumbbells';
      case Equipment.barbell:
        return 'Barbell';
      case Equipment.kettlebell:
        return 'Kettlebell';
      case Equipment.resistanceBands:
        return 'Resistance Bands';
      case Equipment.pullUpBar:
        return 'Pull-up Bar';
      case Equipment.benchPress:
        return 'Bench Press';
      case Equipment.treadmill:
        return 'Treadmill';
      case Equipment.bicycle:
        return 'Bicycle';
      case Equipment.yogaMat:
        return 'Yoga Mat';
      case Equipment.jumpRope:
        return 'Jump Rope';
      case Equipment.medicineBall:
        return 'Medicine Ball';
      case Equipment.foamRoller:
        return 'Foam Roller';
      case Equipment.none:
        return 'No Equipment';
    }
  }
}
