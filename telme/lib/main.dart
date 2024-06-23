import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:telme/constants/dart_theme.dart';
import 'package:telme/constants/light_theme.dart';
import 'package:telme/views/auth/login.dart';
import 'package:telme/views/auth/register.dart';
import 'package:telme/views/sections/wrapper.dart';

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

  // Map defining the routes for the application
  static Map<String, WidgetBuilder> _appRoutes = {
    '/login': (context) => Login(), // Route to Login view
    '/wrapper': (context) => Wrapper(), // Route to Wrapper veiw
    '/register': (context)=> Register(),  // Route to register view 
  };

  // Builds the widget tree
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disables debug banner
      initialRoute: '/login', // Sets the initial route
      routes: _appRoutes, // Defines the routes for the app
      title: 'Tel Me', // Sets the title of the app
      darkTheme: DarkTheme(), // Sets the dark theme
      theme: LightTheme(), // Sets the light theme
    );
  }
}
