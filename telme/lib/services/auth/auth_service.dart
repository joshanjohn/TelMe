import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:telme/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('Users');



  // register a user

  Future<UserCredential> register(UserModel user) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: user.email.toString().trim().toLowerCase(),
      password: user.password.toString().trim(),
    );

    print("UID = "+userCredential.user!.uid);

    if (userCredential.user != null) {
      _userCollection.doc(userCredential.user!.uid).set({
        'userId': userCredential.user!.uid,
        'name': user.name,
        'email': user.email,
        'access': user.access,
      });
    }

    return userCredential;
  }

  //delete a user

  // Login user

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
