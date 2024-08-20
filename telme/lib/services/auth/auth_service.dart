import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telme/models/user_model.dart';

class AuthService {
  // Initializing FirebaseAuth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Reference to the 'Users' collection in Firestore
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('Users');

  // Method to register a new user
  Future<UserCredential?> register(
      {required UserModel user, required String password, required BuildContext context}) async {
    try {
      // Create a new user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: user.email.toString().trim().toLowerCase(),
        password: password,
      );

      if (userCredential.user != null) {
        // Check if account type is employee or employer

        await _userCollection.doc(userCredential.user!.uid).set({
          'userId': userCredential.user!.uid,
          'name': user.name,
          'email': user.email,
          'access': user.access,
        });
      }
      return userCredential; // Return user credentials
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Registration failed")),
      );
      return null;
    }
  }

  Future<void> login(String email, String password, BuildContext context) async {
  try {
    // Attempt to sign in with email and password
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email, // Provided email
      password: password, // Provided password
    );

    // If login is successful, navigate to the '/wrapper' route
    if (credential.user != null) {
      DocumentSnapshot userDoc = await _userCollection.doc(credential.user!.uid).get();
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setBool("logged", true);
      Navigator.pushReplacementNamed(
        context,
        '/wrapper',
        arguments: UserModel.fromJson(userDoc),
      );
      
    }
  } on FirebaseAuthException catch (e) {
    // Handle login error
    List errors = e.toString().split(']');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errors[1])), // Display error message
    );
  }
}


  // Method to log out the current user
  Future<void> logout() async {
    _auth.signOut(); // Sign out from FirebaseAuth
  }
}
