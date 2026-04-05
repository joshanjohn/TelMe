import 'package:flutter/material.dart';

ThemeData LightTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,

    textTheme: const TextTheme(
      //title text
      titleLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),

      titleSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),

      // display text
      displayLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 18, color: Colors.black),
      displaySmall: TextStyle(fontSize: 14, color: Colors.black87),
    ),

    //colors
    hintColor: Colors.black87,
    focusColor: Colors.black,
  );
}
