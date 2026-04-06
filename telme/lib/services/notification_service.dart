import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:telme/models/shift_log_model.dart';
import 'package:telme/models/shift_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final Map<String, Set<int>> _scheduledNotificationIds = {};
  final Map<String, Map<String, String>> _shiftFingerprints = {};
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) {
      return;
    }

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );

    await _plugin.initialize(settings);
    await _requestPermissions();
    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    final macos = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    await macos?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> syncShiftNotifications({
    required String userId,
    required List<Shift> shifts,
    required List<ShiftLog> logs,
  }) async {
    if (kIsWeb) {
      return;
    }

    await initialize();

    final previousIds = _scheduledNotificationIds[userId] ?? <int>{};
    final nextIds = <int>{};
    final nextFingerprints = <String, String>{};
    final logsByShift = <String, ShiftLog>{
      for (final log in logs) log.shiftId: log,
    };
    final now = DateTime.now();

    for (final shift in shifts) {
      final log = logsByShift[shift.id];
      final fingerprint = _fingerprintForShift(shift);
      nextFingerprints[shift.id] = fingerprint;

      final previousFingerprint = _shiftFingerprints[userId]?[shift.id];
      if (previousFingerprint != null && previousFingerprint != fingerprint) {
        await _showImmediate(
          id: _notificationId(userId, shift.id, 1),
          title: 'Shift updated',
          body:
              '${shift.title} now starts at ${_formatTime(shift.startTime)} in ${shift.location}.',
        );
      } else if (previousFingerprint == null && shift.endTime.isAfter(now)) {
        await _showImmediate(
          id: _notificationId(userId, shift.id, 0),
          title: 'New shift assigned',
          body:
              '${shift.title} on ${_formatDate(shift.startTime)} at ${_formatTime(shift.startTime)}.',
        );
      }

      if (shift.endTime.isBefore(now)) {
        continue;
      }

      final clockInReminder =
          shift.startTime.subtract(const Duration(minutes: 10));
      if (clockInReminder.isAfter(now) && log?.clockIn == null) {
        final id = _notificationId(userId, shift.id, 2);
        nextIds.add(id);
        await _scheduleNotification(
          id: id,
          title: 'Time to clock in soon',
          body:
              '${shift.title} starts at ${_formatTime(shift.startTime)}. You can clock in in 10 minutes.',
          scheduledAt: clockInReminder,
        );
      }

      final clockOutReminder =
          shift.endTime.subtract(const Duration(minutes: 10));
      if (clockOutReminder.isAfter(now) && log?.clockOut == null) {
        final id = _notificationId(userId, shift.id, 3);
        nextIds.add(id);
        await _scheduleNotification(
          id: id,
          title: 'Time to clock out soon',
          body:
              '${shift.title} ends at ${_formatTime(shift.endTime)}. Wrap up and get ready to clock out.',
          scheduledAt: clockOutReminder,
        );
      }
    }

    final staleIds = previousIds.difference(nextIds);
    for (final id in staleIds) {
      await _plugin.cancel(id);
    }

    _scheduledNotificationIds[userId] = nextIds;
    _shiftFingerprints[userId] = nextFingerprints;
  }

  Future<void> clearUserNotifications(String userId) async {
    if (kIsWeb) {
      return;
    }

    await initialize();

    for (final id in _scheduledNotificationIds[userId] ?? <int>{}) {
      await _plugin.cancel(id);
    }
    _scheduledNotificationIds.remove(userId);
    _shiftFingerprints.remove(userId);
  }

  Future<void> _showImmediate({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(id, title, body, _details);
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledAt.toUtc(), tz.UTC),
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  NotificationDetails get _details {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'shift_updates',
        'Shift Updates',
        channelDescription: 'Shift assignment and clock reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );
  }

  String _fingerprintForShift(Shift shift) {
    return [
      shift.title,
      shift.location,
      shift.startTime.toIso8601String(),
      shift.endTime.toIso8601String(),
    ].join('|');
  }

  int _notificationId(String userId, String shiftId, int type) {
    var hash = 5381;
    final seed = '$userId|$shiftId|$type';
    for (final codeUnit in seed.codeUnits) {
      hash = ((hash << 5) + hash) + codeUnit;
    }
    return hash.abs() % 2147483647;
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
