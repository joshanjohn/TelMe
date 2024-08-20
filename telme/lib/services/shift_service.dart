import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:telme/models/shift_model.dart';

class ShiftService {
  final _userCollection = FirebaseFirestore.instance.collection('Users');

  // Fetch shifts as a Future
  Future<List<ShiftModel>> fetchShifts({required String userId}) async {
    final _shiftCollection = _userCollection.doc(userId).collection('Shifts');

    try {
      QuerySnapshot querySnapshot = await _shiftCollection.get();
      List<ShiftModel> shifts = querySnapshot.docs.map((doc) {
        return ShiftModel.fromJson(doc);
      }).toList();
      return shifts;
    } catch (e) {
      print('Error fetching shifts: $e');
      return []; // Return an empty list in case of error
    }
  }

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

  String extractShiftStamp({required DateTime dateTime, required String format}) {
      return DateFormat(format).format(dateTime);
    }
}
