import 'package:fitness_app/features/profile/providers/profile_controller.dart';
import 'package:fitness_app/utility/constants/app_colors.dart';
import 'package:fitness_app/utility/responsive_breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveBreakpoints.isTablet(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32 : 20,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 24),
              _buildWelcomeCard(context, isTablet),
              SizedBox(height: 32),
              _buildWeeklyProgress(context, isTablet),
              SizedBox(height: 10),
              _buildWorkoutHistory(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final user = ref.watch(currentUserProfileProvider);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 4,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  user.value!.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  user.value!.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWelcomeCard(BuildContext context, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready for your next challenge?',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 28 : 19,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Your Personalized routine is ready',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: isTablet ? 18 : 16,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryBlue,
                padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'View Today\'s Routine',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Progress',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Expanded(
                  child: _buildProgressCard(
                    context,
                    Icons.refresh,
                    '4/5',
                    'Workouts',
                    isTablet,
                  ),
                ),
                Expanded(
                  child: _buildProgressCard(
                    context,
                    Icons.flash_on,
                    '12',
                    'Day Streak',
                    isTablet,
                  ),
                ),
                Expanded(
                  child: _buildProgressCard(
                    context,
                    Icons.bar_chart,
                    '3500',
                    'Total (kg)',
                    isTablet,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    bool isTablet,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: isTablet ? 32 : 24),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: isTablet ? 28 : 24,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutHistory(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Wourkout History',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        _buildWorkoutItem(context, 'Chest & Triceps', 'Yesterday, 45 Mins'),
        SizedBox(height: 12),
        _buildWorkoutItem(context, 'Leg Day', 'sep 29, 2025, 60 Mins'),
      ],
    );
  }

  Widget _buildWorkoutItem(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Card(
      child: ListTile(
        onTap: () {},
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).textTheme.bodyMedium!.color,
          size: 16,
        ),
      ),
    );
  }
}
