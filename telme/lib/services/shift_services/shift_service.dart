
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/services/user_services/user_service.dart';

class ShiftService {
  final _userCollection = FirebaseFirestore.instance.collection('Users');

  // Fetch shifts as a Stream
  Stream<List<ShiftModel>> fetchShiftsStream({required String userId}) {
    final _shiftCollection = _userCollection.doc(userId).collection('Shifts');

    return _shiftCollection.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return ShiftModel.fromJson(doc);
      }).toList();
    });
  }



  Stream<ShiftModel?> getUpcomingShift() async* {
    final currentTime = DateTime.now();
    final String userId = await UserService().getUserID();

    // Reference to the Firebase location
    final shiftsCollection =
        FirebaseFirestore.instance.collection('/Users/$userId/Shifts');

    // Query shifts where startTime is within 15 minutes and endTime is greater than now
    yield* shiftsCollection
        .where('startTime', isGreaterThanOrEqualTo: currentTime)
        .where('clockOut', isNull: true)
        .where(
          'startTime',
          isLessThanOrEqualTo: currentTime.add(const Duration(minutes: 15)),
        )
        .snapshots()
        .map((snapshot) {
      // Check if there is any shift
      if (snapshot.docs.isNotEmpty) {
        // Return the first shift
        print("fetch upcoming shifts length = ${snapshot.docs.length}");
        print(snapshot.docs.first.get('clockIn'));
        return ShiftModel.fromJson(snapshot.docs.first);
      } else {
        // No upcoming shift found
        return null;
      }
    });
  }

  Future addShift(ShiftModel shift, BuildContext context) async {
    try {
      final String userId = await UserService().getUserID();
      await _userCollection
          .doc(userId)
          .collection('Shifts')
          .doc()
          .set(shift.toJson());
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> markClockIn(String shiftId) async {
    // function to update clock In time
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      String? userId = await _pref.getString('userId');

      _userCollection.doc(userId).collection('Shifts').doc(shiftId).update({
        'clockIn': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }


  Future<void> markClockOut(String shiftId) async {
    // function to update clock In time
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      String? userId = await _pref.getString('userId');

      _userCollection.doc(userId).collection('Shifts').doc(shiftId).update({
        'clockOut': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }
}
