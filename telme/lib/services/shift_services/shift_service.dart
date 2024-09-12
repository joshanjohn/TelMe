import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // Fetch the current shift based on current time
  Stream<ShiftModel?> getCurrentShift({required String userId}) {
    final _shiftCollection = _userCollection.doc(userId).collection('Shifts');

    return _shiftCollection.snapshots().map((querySnapshot) {
      final now = DateTime.now();
      final closestShiftDoc = querySnapshot.docs.where((doc) {
        final shift = ShiftModel.fromJson(doc);
        return shift.startTime.isAfter(now) &&
            shift.startTime.isBefore(now.add(Duration(minutes: 15)));
      }).toList();

      if (closestShiftDoc.isNotEmpty) {
        return ShiftModel.fromJson(closestShiftDoc.first);
      } else {
        return null; // No current shift found
      }
    });
  }

  String extractShiftStamp(
      {required DateTime dateTime, required String format}) {
    return DateFormat(format).format(dateTime);
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
        .where(
          'startTime',
          isLessThanOrEqualTo: currentTime.add(Duration(minutes: 15)),
        )
        .snapshots()
        .map((snapshot) {
      // Check if there is any shift
      if (snapshot.docs.isNotEmpty) {
        // Return the first shift
        print(snapshot.docs.length);
        return ShiftModel.fromJson(snapshot.docs[0]);
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
}
