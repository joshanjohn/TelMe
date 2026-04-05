import 'package:telme/models/profile_model.dart';

class Shift {
  final String id;
  final String title;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String? createdBy;
  final DateTime createdAt;
  final List<Profile> assignedEmployees;

  Shift({
    required this.id,
    required this.title,
    required this.location,
    required this.startTime,
    required this.endTime,
    this.createdBy,
    required this.createdAt,
    this.assignedEmployees = const [],
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      startTime: json['start_time'] != null 
          ? DateTime.parse(json['start_time']) 
          : DateTime.now(),
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time']) 
          : DateTime.now(),
      createdBy: json['created_by'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      assignedEmployees: (json['assigned_employees'] as List?)
              ?.map((e) => Profile.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'location': location,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'created_by': createdBy,
    };
  }
}
