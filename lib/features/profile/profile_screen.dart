import 'package:fitness_app/models/user_profile.dart';
import 'package:fitness_app/utility/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Your Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomSection(),
                SizedBox(height: 20),
                _buildPersonalInfoSection(),
                SizedBox(height: 20),
                _buildGoalSection(),
                _buildLevelSection(),
                SizedBox(height: 20),
                _buildCreateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomSection() {
    return Container(
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
          Icon(Icons.person_add, size: 48, color: Colors.white),
          Text(
            'Let\'s Get Started!',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(color: Colors.white),
          ),
          Text(
            'Tell us about yourself to create a personalized fitness experience',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          'Personal Information',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),

        // Age and Weight
        Row(
          spacing: 16,
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age',
                  prefixIcon: Icon(Icons.cake_outlined),
                  suffixText: 'Years',
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Weight',
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                  suffixText: 'Kg',
                ),
              ),
            ),
          ],
        ),

        // height field
        TextFormField(
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Height',
            prefixIcon: Icon(Icons.height_outlined),
            suffixText: 'Cm',
          ),
        ),
      ],
    );
  }

  Widget _buildGoalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fitness Goal', style: Theme.of(context).textTheme.headlineMedium),

        ...Goal.values.map((goal) {
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textSecondary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.transparent,
                ),
                child: Row(
                  spacing: 5,
                  children: [
                    Icon(_getGoalIcon(goal), color: AppColors.textSecondary),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_getGoalTitle(goal)),
                          Text(_getGoalDescription(goal)),
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
  }

  Widget _buildLevelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fitness Level',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Row(
          children: Level.values.map((level) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.textSecondary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        Icon(_getLevelIcon(level)),
                        Text(_getLevelTitle(level)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/home');
        },
        child: Text('Create Profile'),
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
        return Icons.sentiment_satisfied;
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
}
