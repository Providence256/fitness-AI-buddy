import 'package:fitness_app/service/gemini_service.dart';
import 'package:fitness_app/utility/app_theme.dart';
import 'package:fitness_app/utility/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //Initiliaze Gemini API
  // Gemini.init(apiKey: 'AIzaSyDbrb1OQnJSXpVKFPNc3HltDi4_HXdqrno');

  GeminiService.init(apiKey: 'AIzaSyDbrb1OQnJSXpVKFPNc3HltDi4_HXdqrno');

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: RouteGenerator.generateRoute,
      initialRoute: '/',
    );
  }
}
