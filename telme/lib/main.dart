import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:telme/utils/constants/dart_theme.dart';
import 'package:telme/utils/constants/light_theme.dart';
import 'package:telme/router/routes.dart';

void main() async {
  // Ensures Flutter framework is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  // Initializes Firebase
  await Firebase.initializeApp();
  // Runs the MyApp widget
  runApp(const MyApp());
}

// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Builds the widget tree
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false, // Disables debug banner
      routerConfig: appRouter,
      title: 'Tel Me', // Sets the title of the app
      darkTheme: DarkTheme(), // Sets the dark theme
      theme: LightTheme(), // Sets the light theme
    );
  }
}
