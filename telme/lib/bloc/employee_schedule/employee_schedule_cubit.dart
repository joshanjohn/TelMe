import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:telme/models/shift_log_model.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/services/shift_repository.dart';

enum EmployeeScheduleStatus { initial, loading, loaded, failure }

class EmployeeScheduleState extends Equatable {
  const EmployeeScheduleState({
    this.status = EmployeeScheduleStatus.initial,
    required this.selectedDate,
    this.shifts = const [],
    this.logs = const [],
    this.errorMessage,
  });

  final EmployeeScheduleStatus status;
  final DateTime selectedDate;
  final List<Shift> shifts;
  final List<ShiftLog> logs;
  final String? errorMessage;

  DateTime get weekStart {
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    ).subtract(Duration(days: selectedDate.weekday - 1));
  }

  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  List<Shift> get weeklyShifts {
    final filtered = shifts
        .where((shift) => _isShiftInWeek(shift.startTime, weekStart))
        .toList();
    filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
    return filtered;
  }

  ShiftLog? logForShift(String shiftId) {
    for (final log in logs) {
      if (log.shiftId == shiftId) {
        return log;
      }
    }
    return null;
  }

  EmployeeScheduleState copyWith({
    EmployeeScheduleStatus? status,
    DateTime? selectedDate,
    List<Shift>? shifts,
    List<ShiftLog>? logs,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return EmployeeScheduleState(
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      shifts: shifts ?? this.shifts,
      logs: logs ?? this.logs,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, selectedDate, shifts, logs, errorMessage];
}

class EmployeeScheduleCubit extends Cubit<EmployeeScheduleState> {
  EmployeeScheduleCubit({
    required ShiftRepository shiftRepository,
    required this.userId,
  })  : _shiftRepository = shiftRepository,
        super(EmployeeScheduleState(selectedDate: DateTime.now()));

  final ShiftRepository _shiftRepository;
  final String userId;
  StreamSubscription<({List<Shift> shifts, List<ShiftLog> logs})>?
      _subscription;

  void subscribe() {
    emit(state.copyWith(
        status: EmployeeScheduleStatus.loading, clearErrorMessage: true));

    _subscription?.cancel();
    _subscription = CombineLatestStream.combine2<List<Shift>, List<ShiftLog>,
        ({List<Shift> shifts, List<ShiftLog> logs})>(
      _shiftRepository.myShiftsStream(userId),
      _shiftRepository.userLogsStream(userId),
      (shifts, logs) => (shifts: shifts, logs: logs),
    ).listen(
      (data) {
        emit(
          state.copyWith(
            status: EmployeeScheduleStatus.loaded,
            shifts: data.shifts,
            logs: data.logs,
            clearErrorMessage: true,
          ),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        emit(
          state.copyWith(
            status: EmployeeScheduleStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

bool _isShiftInWeek(DateTime date, DateTime weekStart) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final normalizedStart =
      DateTime(weekStart.year, weekStart.month, weekStart.day);
  final normalizedEnd = normalizedStart.add(const Duration(days: 6));
  return !normalizedDate.isBefore(normalizedStart) &&
      !normalizedDate.isAfter(normalizedEnd);
}
