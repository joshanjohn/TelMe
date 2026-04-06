import 'package:equatable/equatable.dart';

enum UserRole { admin, employee }

class Profile extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final DateTime createdAt;

  const Profile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? 'Unknown',
      email: json['email'] ?? '',
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.employee,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, fullName, email, role, createdAt];
}
