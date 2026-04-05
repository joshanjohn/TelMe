import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/models/shift_log_model.dart';

class ShiftRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all shifts with assignments
  Future<List<Shift>> getAllShifts() async {
    final response = await _supabase
        .from('detailed_shifts')
        .select()
        .order('start_time');
    return (response as List).map((json) => Shift.fromJson(json)).toList();
  }

  // Stream of only shifts assigned to a specific user
  Stream<List<Shift>> myShiftsStream(String userId) => _supabase
      .from('shifts')
      .stream(primaryKey: ['id'])
      .order('start_time')
      .asyncMap((data) async {
        try {
          final ids = data.map((d) => d['id']).toList();
          if (ids.isEmpty) return [];
          
          final response = await _supabase
              .from('detailed_shifts')
              .select()
              .inFilter('id', ids)
              .order('start_time')
              .timeout(const Duration(seconds: 10));
              
          return (response as List)
              .map((json) => Shift.fromJson(json))
              .where((s) => s.assignedEmployees.any((p) => p.id == userId))
              .toList();
        } catch (e) {
          print('Assigned shifts stream error: $e');
          throw e;
        }
      });

  // Stream of all shifts for Admin
  Stream<List<Shift>> get shiftsStream => _supabase
      .from('shifts')
      .stream(primaryKey: ['id'])
      .order('start_time')
      .asyncMap((data) async {
        try {
          final ids = data.map((d) => d['id']).toList();
          if (ids.isEmpty) return [];
          
          final response = await _supabase
              .from('detailed_shifts')
              .select()
              .inFilter('id', ids)
              .order('start_time')
              .timeout(const Duration(seconds: 10));
              
          return (response as List).map((json) => Shift.fromJson(json)).toList();
        } catch (e) {
          print('Admin shifts stream error: $e');
          throw e;
        }
      });

  // Stream of logs for a specific user
  Stream<List<ShiftLog>> userLogsStream(String userId) => _supabase
      .from('shift_logs')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .map((data) => data.map((json) => ShiftLog.fromJson(json)).toList());

  // Create a shift and assign employees
  Future<void> createShift(Shift shift, List<String> employeeIds) async {
    final shiftResponse = await _supabase
        .from('shifts')
        .insert(shift.toJson())
        .select()
        .single();
    
    final shiftId = shiftResponse['id'];

    if (employeeIds.isNotEmpty) {
      final assignments = employeeIds.map((userId) => {
        'shift_id': shiftId,
        'user_id': userId,
      }).toList();
      
      await _supabase.from('shift_assignments').insert(assignments);
    }
  }

  // Edit an existing shift
  Future<void> updateShift(Shift shift, List<String> employeeIds) async {
    // 1. Update basic shift info
    await _supabase
        .from('shifts')
        .update(shift.toJson())
        .eq('id', shift.id);

    // 2. Update assignments (simplest way: delete all and re-add)
    await _supabase
        .from('shift_assignments')
        .delete()
        .eq('shift_id', shift.id);

    if (employeeIds.isNotEmpty) {
      final assignments = employeeIds.map((userId) => {
        'shift_id': shift.id,
        'user_id': userId,
      }).toList();
      
      await _supabase.from('shift_assignments').insert(assignments);
    }
  }

  // Delete a shift
  Future<void> deleteShift(String shiftId) async {
    await _supabase.from('shifts').delete().eq('id', shiftId);
  }

  Future<void> clockIn(String shiftId, String userId) async {
    final now = DateTime.now();
    final shift = await getShiftById(shiftId);
    
    final diff = now.difference(shift.startTime).inMinutes;
    if (diff < -10) {
      throw Exception('You can only clock in starting 10 minutes before the shift.');
    }

    await _supabase.from('shift_logs').upsert({
      'shift_id': shiftId,
      'user_id': userId,
      'clock_in': now.toIso8601String(),
    });
  }

  Future<void> clockOut(String shiftId, String userId) async {
    final now = DateTime.now();
    final shift = await getShiftById(shiftId);

    final diff = now.difference(shift.endTime).inMinutes;
    if (diff < -10) {
      throw Exception('You can only clock out starting 10 minutes before the shift ends.');
    }

    await _supabase.from('shift_logs').update({
      'clock_out': now.toIso8601String(),
    }).match({'shift_id': shiftId, 'user_id': userId});
  }

  Future<Shift> getShiftById(String id) async {
    final response = await _supabase
        .from('detailed_shifts')
        .select()
        .eq('id', id)
        .single();
    return Shift.fromJson(response);
  }
}
