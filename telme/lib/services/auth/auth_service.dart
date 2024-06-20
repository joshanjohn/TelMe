import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login(
      String email, String password, BuildContext context) async {
    try {
      //try get credentials from supplied email and password
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential != null) {
        Navigator.pushReplacementNamed(
          context,
          '/wrapper',
        );
      }
    } on FirebaseAuthException catch (e) {
      List errors = e.toString().split(']');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errors[1])),
      );
    }
  }

  Future<void> logout() async {
     _auth.signOut();
  }
}
