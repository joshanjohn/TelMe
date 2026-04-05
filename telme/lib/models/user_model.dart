import 'package:cloud_firestore/cloud_firestore.dart';

// This class represents a user model with various properties like userId, name, email, access, and password.
class UserModel {
  String? userId; // User ID, optional field.
  String? name; // Name of the user, optional field.
  String? email; // Email of the user, optional field.
  String? access; // Access level of the user, optional field.

  // Constructor to initialize a UserModel object with optional fields.
  UserModel({
    this.userId,
    this.name,
    this.email,
    this.access,
  });

  // Factory constructor to create a UserModel object from a Firestore document snapshot.
  factory UserModel.fromJson(DocumentSnapshot data) {
    return UserModel(
      userId: data['userId'], // Fetches the userId field from Firestore document.
      name: data['name'], // Fetches the name field from Firestore document.
      email: data['email'], // Fetches the email field from Firestore document.
      access: data['access'], // Fetches the access field from Firestore document.
    );
  }

  // Method to convert a UserModel object to a map (JSON) for storage in Firestore.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId, // Converts userId field to JSON.
      'name': name, // Converts name field to JSON.
      'email': email, // Converts email field to JSON.
      'access': access, // Converts access field to JSON.
    };
  }
}
