import 'package:flutter/material.dart';

ThemeData DarkTheme() {
  return ThemeData(
    colorScheme:
        ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 8, 3, 56)),

    useMaterial3: true,
    scaffoldBackgroundColor: const Color.fromARGB(255, 13, 5, 75),

    textTheme: const TextTheme(
      //title text
      titleLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),

      titleSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white70,
      ),

      //display text
      displayLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      displayMedium: TextStyle(fontSize: 18, color: Colors.white),
      displaySmall: TextStyle(fontSize: 14, color: Colors.white70),
    ),

    //colors
    hintColor: Colors.white70,
    focusColor: Colors.white,
  );
}
