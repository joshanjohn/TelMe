import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/models/shift_log_model.dart';

class ShiftRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, Stream<List<Shift>>> _myShiftStreams = {};
  final Map<String, List<Shift>> _myShiftCache = {};
  final Map<String, Stream<List<ShiftLog>>> _userLogStreams = {};
  final Map<String, List<ShiftLog>> _userLogCache = {};
  final Map<String, Stream<({Shift? shift, ShiftLog? log})>>
      _nextClockableShiftStreams = {};
  Stream<List<Shift>>? _adminShiftStream;
  List<Shift> _adminShiftCache = const [];

  // Fetch all shifts with assignments
  Future<List<Shift>> getAllShifts() async {
    if (_adminShiftCache.isNotEmpty) {
      return _adminShiftCache;
    }

    final shifts = await _fetchDetailedShifts();
    _adminShiftCache = shifts;
    return shifts;
  }

  // Stream of only shifts assigned to a specific user
  Stream<List<Shift>> myShiftsStream(String userId) {
    return _myShiftStreams.putIfAbsent(userId, () {
      final assignmentStream = _supabase
          .from('shift_assignments')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .map((rows) => rows.cast<Map<String, dynamic>>());

      final shiftUpdateStream = _supabase.from('shifts').stream(
          primaryKey: ['id']).map((rows) => rows.cast<Map<String, dynamic>>());

      final stream = CombineLatestStream.combine2<List<Map<String, dynamic>>,
          List<Map<String, dynamic>>, List<Map<String, dynamic>>>(
        assignmentStream,
        shiftUpdateStream,
        (assignments, _) => assignments,
      ).asyncMap<List<Shift>>((assignments) async {
        try {
          final ids =
              assignments.map((a) => a['shift_id'] as String).toSet().toList();
          if (ids.isEmpty) {
            return <Shift>[];
          }

          return await _fetchDetailedShifts(ids: ids);
        } catch (e) {
          debugPrint('Assigned shifts stream error: $e');
          return _myShiftCache[userId] ?? const <Shift>[];
        }
      }).map((shifts) {
        _myShiftCache[userId] = shifts;
        return shifts;
      });

      return stream.asBroadcastStream();
    });
  }

  // Stream of all shifts for Admin
  Stream<List<Shift>> get shiftsStream {
    return _adminShiftStream ??= CombineLatestStream.combine2<
        List<Map<String, dynamic>>,
        List<Map<String, dynamic>>,
        List<Map<String, dynamic>>>(
      _supabase.from('shifts').stream(
          primaryKey: ['id']).map((rows) => rows.cast<Map<String, dynamic>>()),
      _supabase.from('shift_assignments').stream(
          primaryKey: ['id']).map((rows) => rows.cast<Map<String, dynamic>>()),
      (shifts, _) => shifts,
    ).asyncMap<List<Shift>>((data) async {
      try {
        final ids = data.map((d) => d['id'] as String).toList();
        if (ids.isEmpty) {
          return <Shift>[];
        }

        return await _fetchDetailedShifts(ids: ids);
      } catch (e) {
        debugPrint('Admin shifts stream error: $e');
        return _adminShiftCache;
      }
    }).map((shifts) {
      _adminShiftCache = shifts;
      return shifts;
    }).asBroadcastStream();
  }

  // Stream of logs for a specific user
  Stream<List<ShiftLog>> userLogsStream(String userId) {
    return _userLogStreams.putIfAbsent(userId, () {
      final stream = _supabase
          .from('shift_logs')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .map((data) => data.map((json) => ShiftLog.fromJson(json)).toList())
          .map((logs) {
            _userLogCache[userId] = logs;
            return logs;
          });

      return stream.asBroadcastStream();
    });
  }

  Stream<({Shift? shift, ShiftLog? log})> watchNextClockableShift(
      String userId) {
    return _nextClockableShiftStreams.putIfAbsent(userId, () {
      final stream = CombineLatestStream.combine2<List<Shift>, List<ShiftLog>,
          ({Shift? shift, ShiftLog? log})>(
        myShiftsStream(userId),
        userLogsStream(userId),
        (shifts, logs) => _resolveNextClockableShift(shifts, logs),
      ).distinct((previous, next) =>
          previous.shift?.id == next.shift?.id &&
          previous.log?.clockIn == next.log?.clockIn &&
          previous.log?.clockOut == next.log?.clockOut);

      return stream.asBroadcastStream();
    });
  }

  Future<ShiftLog?> getShiftLog(String shiftId, String userId) async {
    final cachedLogs = _userLogCache[userId];
    if (cachedLogs != null) {
      for (final log in cachedLogs) {
        if (log.shiftId == shiftId) {
          return log;
        }
      }
    }

    final response = await _supabase
        .from('shift_logs')
        .select()
        .eq('shift_id', shiftId)
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return ShiftLog.fromJson(response);
  }

  // Create a shift and assign employees
  Future<void> createShift(Shift shift, List<String> employeeIds) async {
    final shiftResponse =
        await _supabase.from('shifts').insert(shift.toJson()).select().single();

    final shiftId = shiftResponse['id'];

    if (employeeIds.isNotEmpty) {
      final assignments = employeeIds
          .map((userId) => {
                'shift_id': shiftId,
                'user_id': userId,
              })
          .toList();

      await _supabase.from('shift_assignments').insert(assignments);
    }

    _invalidateShiftCaches(employeeIds: employeeIds);
  }

  // Edit an existing shift
  Future<void> updateShift(Shift shift, List<String> employeeIds) async {
    // 1. Update basic shift info
    await _supabase.from('shifts').update(shift.toJson()).eq('id', shift.id);

    // 2. Update assignments (simplest way: delete all and re-add)
    await _supabase.from('shift_assignments').delete().eq('shift_id', shift.id);

    if (employeeIds.isNotEmpty) {
      final assignments = employeeIds
          .map((userId) => {
                'shift_id': shift.id,
                'user_id': userId,
              })
          .toList();

      await _supabase.from('shift_assignments').insert(assignments);
    }

    _invalidateShiftCaches(employeeIds: employeeIds);
  }

  // Delete a shift
  Future<void> deleteShift(String shiftId) async {
    await _supabase.from('shifts').delete().eq('id', shiftId);
    _invalidateShiftCaches();
  }

  Future<Shift?> getImminentShift(String userId) async {
    final cachedShifts = _myShiftCache[userId];
    final cachedLogs = _userLogCache[userId];
    if (cachedShifts != null && cachedLogs != null) {
      return _resolveNextClockableShift(cachedShifts, cachedLogs).shift;
    }

    final shifts = await _fetchMyShifts(userId);
    final logs = await userLogsStream(userId).first;
    return _resolveNextClockableShift(shifts, logs).shift;
  }

  Future<void> clockIn(String shiftId, String userId) async {
    final now = DateTime.now();
    final shift = await getShiftById(shiftId);

    final diff = now.difference(shift.startTime).inMinutes;
    if (diff < -10) {
      throw Exception(
          'You can only clock in starting 10 minutes before the shift.');
    }

    await _supabase.from('shift_logs').upsert({
      'shift_id': shiftId,
      'user_id': userId,
      'clock_in': now.toIso8601String(),
    });

    _invalidateLogCache(userId);
  }

  Future<void> clockOut(String shiftId, String userId) async {
    final now = DateTime.now();
    final shift = await getShiftById(shiftId);

    final diff = now.difference(shift.endTime).inMinutes;
    if (diff < -10) {
      throw Exception(
          'You can only clock out starting 10 minutes before the shift ends.');
    }

    await _supabase.from('shift_logs').update({
      'clock_out': now.toIso8601String(),
    }).match({'shift_id': shiftId, 'user_id': userId});

    _invalidateLogCache(userId);
  }

  Future<Shift> getShiftById(String id) async {
    final response =
        await _supabase.from('detailed_shifts').select().eq('id', id).single();
    return Shift.fromJson(response);
  }

  Future<List<Shift>> _fetchMyShifts(String userId) async {
    final response = await _supabase
        .from('shift_assignments')
        .select('shift_id')
        .eq('user_id', userId);

    final ids = (response as List)
        .map((item) => item['shift_id'] as String)
        .toSet()
        .toList();

    final shifts = await _fetchDetailedShifts(ids: ids);
    _myShiftCache[userId] = shifts;
    return shifts;
  }

  Future<List<Shift>> _fetchDetailedShifts({List<String>? ids}) async {
    final query = _supabase.from('detailed_shifts').select();
    final response = ids == null || ids.isEmpty
        ? await query.order('start_time').timeout(const Duration(seconds: 10))
        : await query
            .inFilter('id', ids)
            .order('start_time')
            .timeout(const Duration(seconds: 10));

    return (response as List).map((json) => Shift.fromJson(json)).toList();
  }

  ({Shift? shift, ShiftLog? log}) _resolveNextClockableShift(
    List<Shift> shifts,
    List<ShiftLog> logs,
  ) {
    final logsByShift = <String, ShiftLog>{
      for (final log in logs) log.shiftId: log,
    };
    final now = DateTime.now();

    Shift? bestShift;
    ShiftLog? bestLog;

    for (final shift in [...shifts]
      ..sort((a, b) => a.startTime.compareTo(b.startTime))) {
      final log = logsByShift[shift.id];
      if (log?.clockIn != null || shift.endTime.isBefore(now)) {
        continue;
      }

      bestShift = shift;
      bestLog = log;
      break;
    }

    return (shift: bestShift, log: bestLog);
  }

  void _invalidateShiftCaches({List<String> employeeIds = const []}) {
    _adminShiftCache = const [];
    for (final userId in employeeIds) {
      _myShiftCache.remove(userId);
    }
  }

  void _invalidateLogCache(String userId) {
    _userLogCache.remove(userId);
  }
}
