import 'package:cloud_firestore/cloud_firestore.dart';

class ShiftModel {
  String? shiftId;
  String name;
  String location;
  DateTime startTime;
  DateTime endTime;
  DateTime? clockIn;
  DateTime? clockOut;

  ShiftModel({
    this.shiftId,
    required this.name,
    required this.location,
    required this.startTime,
    required this.endTime,
    this.clockIn,
    this.clockOut,
  });


  

  factory ShiftModel.fromJson(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShiftModel(
      shiftId: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      clockIn: data['clockIn'] != null ? (data['clockIn'] as Timestamp).toDate() : null,
      clockOut: data['clockOut'] != null ? (data['clockOut'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'clockIn': clockIn != null ? Timestamp.fromDate(clockIn!) : null,
      'clockOut': clockOut != null ? Timestamp.fromDate(clockOut!) : null,
    };
  }
}
