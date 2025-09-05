import 'package:fitness_app/features/authentication/auth_screen.dart';
import 'package:fitness_app/features/history/history_screen.dart';
import 'package:fitness_app/features/profile/profile_screen.dart';
import 'package:fitness_app/features/progress/progress_screen.dart';
import 'package:fitness_app/widgets/common/responsive_navigation.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _buildRoute(AuthScreen(), settings);
      case '/home':
        return _buildRoute(ResponsiveNavigation(), settings);
      case '/progress':
        return _buildRoute(ProgressScreen(), settings);
      case '/history':
        return _buildRoute(HistoryScreen(), settings);
      case '/profile':
        return _buildRoute(ProfileScreen(), settings);

      default:
        return _buildErrorRoute('Page not found: ${settings.name}');
    }
  }

  static Route<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => page, settings: settings);
  }

  static Route<dynamic> _buildErrorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                ),
                child: Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
