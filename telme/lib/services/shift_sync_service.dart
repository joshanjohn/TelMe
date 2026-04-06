import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:telme/models/shift_log_model.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/services/notification_service.dart';
import 'package:telme/services/shift_repository.dart';

class ShiftSyncService {
  ShiftSyncService({
    required ShiftRepository shiftRepository,
    required NotificationService notificationService,
  })  : _shiftRepository = shiftRepository,
        _notificationService = notificationService;

  final ShiftRepository _shiftRepository;
  final NotificationService _notificationService;

  StreamSubscription<({List<Shift> shifts, List<ShiftLog> logs})>?
      _subscription;
  String? _activeUserId;

  Future<void> startForUser(String userId) async {
    if (_activeUserId == userId && _subscription != null) {
      return;
    }

    await stop();
    _activeUserId = userId;

    _subscription = CombineLatestStream.combine2<List<Shift>, List<ShiftLog>,
        ({List<Shift> shifts, List<ShiftLog> logs})>(
      _shiftRepository.myShiftsStream(userId),
      _shiftRepository.userLogsStream(userId),
      (shifts, logs) => (shifts: shifts, logs: logs),
    ).listen((data) {
      _notificationService.syncShiftNotifications(
        userId: userId,
        shifts: data.shifts,
        logs: data.logs,
      );
    });
  }

  Future<void> stop() async {
    final activeUserId = _activeUserId;
    await _subscription?.cancel();
    _subscription = null;
    _activeUserId = null;

    if (activeUserId != null) {
      await _notificationService.clearUserNotifications(activeUserId);
    }
  }
}
