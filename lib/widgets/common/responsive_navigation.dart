import 'package:fitness_app/features/exercise/exercise_screen.dart';
import 'package:fitness_app/features/home/home_screen.dart';
import 'package:fitness_app/features/progress/progress_screen.dart';
import 'package:fitness_app/features/workout/workout_screen.dart';
import 'package:fitness_app/utility/responsive_breakpoints.dart';
import 'package:flutter/material.dart';

class ResponsiveNavigation extends StatefulWidget {
  const ResponsiveNavigation({super.key});

  @override
  State<ResponsiveNavigation> createState() => _ResponsiveNavigationState();
}

class _ResponsiveNavigationState extends State<ResponsiveNavigation> {
  int selectedIndex = 0;

  final List<AppDestination> destinations = [
    AppDestination(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      page: HomeScreen(),
    ),
    AppDestination(
      label: 'Exercises',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      page: ExerciseScreen(),
    ),
    AppDestination(
      label: 'Workouts',
      icon: Icons.fitness_center_outlined,
      selectedIcon: Icons.fitness_center,
      page: WorkoutScreen(),
    ),
    AppDestination(
      label: 'Progress',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      page: ProgressScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (ResponsiveBreakpoints.isDesktop(context)) {
      return _buildDesktopLayout();
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            onDestinationSelected: _onDestinationSelected,
            destinations: destinations.map(_buildRailDestination).toList(),
            selectedIndex: selectedIndex,
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(child: destinations[selectedIndex].page),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            destinations: destinations.map(_buildRailDestination).toList(),
            onDestinationSelected: _onDestinationSelected,
            selectedIndex: selectedIndex,
          ),
          VerticalDivider(thickness: 1, width: 1),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: destinations[selectedIndex].page,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Generate workout',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: () {},
        child: Icon(Icons.star_rounded),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 1,
        currentIndex: selectedIndex,
        onTap: _onDestinationSelected,
        items: destinations.map(_buildBottomDestination).toList(),
      ),
    );
  }

  NavigationRailDestination _buildRailDestination(AppDestination dest) {
    return NavigationRailDestination(
      icon: Icon(dest.icon),
      label: Text(dest.label),
      selectedIcon: Icon(dest.selectedIcon),
    );
  }

  BottomNavigationBarItem _buildBottomDestination(AppDestination dest) {
    return BottomNavigationBarItem(
      icon: Icon(dest.icon),
      label: dest.label,
      activeIcon: Icon(dest.selectedIcon),
    );
  }

  void _onDestinationSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}

class AppDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;

  AppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });
}
