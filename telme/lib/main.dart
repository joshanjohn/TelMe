import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:telme/constants/dart_theme.dart';
import 'package:telme/constants/light_theme.dart';
import 'package:telme/views/auth/login.dart';
import 'package:telme/views/auth/register.dart';
import 'package:telme/views/sections/shift/add_shift.dart';
import 'package:telme/views/sections/wrapper.dart';
import 'package:telme/models/user_model.dart';

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

  // Route generator function to handle route creation with parameters
  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (context) => const Login());
      case '/addShift':
        return MaterialPageRoute(builder: (context) => AddShift());
      case '/register':
        return MaterialPageRoute(builder: (context) => const Register());
      case '/wrapper':
        // Extract the UserModel argument from route settings
        final args = settings.arguments as UserModel;
        return MaterialPageRoute(
          builder: (context) => Wrapper(user: args),
        );
      default:
        return MaterialPageRoute(builder: (context) => const Login());
    }
  }

  // Builds the widget tree
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disables debug banner
      initialRoute: '/login', // Sets the initial route
      onGenerateRoute: _generateRoute, // Defines the route generator
      title: 'Tel Me', // Sets the title of the app
      darkTheme: DarkTheme(), // Sets the dark theme
      theme: LightTheme(), // Sets the light theme
    );
  }
}