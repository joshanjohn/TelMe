import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:telme/models/user_model.dart';

class AuthService {
  // Initializing FirebaseAuth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Reference to the 'Users' collection in Firestore
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('Users');

  final CollectionReference _employeesCollection =
      FirebaseFirestore.instance.collection('Employees');
  final CollectionReference _employersCollection =
      FirebaseFirestore.instance.collection('Employers');

  // Method to register a new user
  Future<UserCredential> register(UserModel user, String accountType) async {
    // Create a new user with email and password
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: user.email.toString().trim().toLowerCase(), // Clean email input
      password: user.password.toString().trim(), // Clean password input
    );

    print("UID = " + userCredential.user!.uid); // Print user ID for debugging

    // If user creation was successful, add user data to Firestore

    if (userCredential.user != null) {
      //check if account type is employee or employer
      if (accountType == "Employee") {
        _employeesCollection.doc(userCredential.user!.uid).set({
          'id': userCredential.user!.uid, // Store user ID
          'name': user.name, // Store user name
          'email': user.email, // Store user email
          'access': user.access, // Store user access level
        });
      } else if (accountType == "Employer") {
        _employersCollection.doc(userCredential.user!.uid).set({
          'id': userCredential.user!.uid, // Store user ID
          'name': user.name, // Store user name
          'email': user.email, // Store user email
          'access': user.access, // Store user access level
        });
      } else {
        _userCollection.doc(userCredential.user!.uid).set({
          'id': userCredential.user!.uid, // Store user ID
          'name': user.name, // Store user name
          'email': user.email, // Store user email
          'access': user.access, // Store user access level
        });
      }
    }

    return userCredential; // Return user credentials
  }

  // Method to log in an existing user
  //TODO
  //require user to be a part of a company's shift
  Future<void> login(
      String email, String password, BuildContext context) async {
    try {
      // Attempt to sign in with email and password
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email, // Provided email
        password: password, // Provided password
      );

      // If login is successful, navigate to the '/wrapper' route
      if (credential != null) {
        Navigator.pushReplacementNamed(
          context,
          '/wrapper',
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
