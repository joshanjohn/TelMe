import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:telme/views/auth/authenticate.dart';
import 'package:telme/constants/dart_theme.dart';
import 'package:telme/constants/light_theme.dart';
import 'package:telme/views/sections/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/home': (context) => Home(),
        '/': (context) => Authenticate(),
      },
      title: 'Flutter Demo',
      darkTheme: DarkTheme(),
      theme: LightTheme(),
    );
  }
}
