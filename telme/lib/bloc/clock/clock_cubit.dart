import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:telme/models/shift_log_model.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/services/shift_repository.dart';

enum ClockStatus { initial, loading, ready, success, empty, failure }

class ClockState extends Equatable {
  const ClockState({
    this.status = ClockStatus.initial,
    this.currentShift,
    this.currentLog,
    this.isSubmitting = false,
    this.message,
    this.successTitle,
  });

  final ClockStatus status;
  final Shift? currentShift;
  final ShiftLog? currentLog;
  final bool isSubmitting;
  final String? message;
  final String? successTitle;

  bool get isClockedIn => currentLog?.clockIn != null;
  bool get isClockedOut => currentLog?.clockOut != null;

  ClockState copyWith({
    ClockStatus? status,
    Shift? currentShift,
    ShiftLog? currentLog,
    bool? isSubmitting,
    String? message,
    String? successTitle,
    bool clearShift = false,
    bool clearLog = false,
    bool clearMessage = false,
    bool clearSuccessTitle = false,
  }) {
    return ClockState(
      status: status ?? this.status,
      currentShift: clearShift ? null : (currentShift ?? this.currentShift),
      currentLog: clearLog ? null : (currentLog ?? this.currentLog),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      message: clearMessage ? null : (message ?? this.message),
      successTitle:
          clearSuccessTitle ? null : (successTitle ?? this.successTitle),
    );
  }

  @override
  List<Object?> get props =>
      [status, currentShift, currentLog, isSubmitting, message, successTitle];
}

class ClockCubit extends Cubit<ClockState> {
  ClockCubit({
    required ShiftRepository shiftRepository,
    required this.userId,
  })  : _shiftRepository = shiftRepository,
        super(const ClockState(status: ClockStatus.loading)) {
    _logsSubscription = _shiftRepository.userLogsStream(userId).listen(
      (logs) {
        final shiftId = state.currentShift?.id;
        if (shiftId == null) {
          return;
        }

        ShiftLog? matchingLog;
        for (final log in logs) {
          if (log.shiftId == shiftId) {
            matchingLog = log;
            break;
          }
        }

        if (matchingLog != state.currentLog) {
          emit(state.copyWith(
              currentLog: matchingLog, clearLog: matchingLog == null));
        }
      },
    );
  }

  final ShiftRepository _shiftRepository;
  final String userId;
  late final StreamSubscription<List<ShiftLog>> _logsSubscription;

  Future<void> load() async {
    emit(state.copyWith(
      status: ClockStatus.loading,
      isSubmitting: false,
      clearMessage: true,
      clearSuccessTitle: true,
    ));

    try {
      final shift = await _shiftRepository.getImminentShift(userId);

      if (shift == null) {
        emit(
          state.copyWith(
            status: ClockStatus.empty,
            clearShift: true,
            clearLog: true,
          ),
        );
        return;
      }

      final log = await _shiftRepository.getShiftLog(shift.id, userId);
      emit(
        state.copyWith(
          status: ClockStatus.ready,
          currentShift: shift,
          currentLog: log,
          isSubmitting: false,
          clearSuccessTitle: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ClockStatus.failure,
          isSubmitting: false,
          message: error.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> submitClockIn() async {
    final shift = state.currentShift;
    if (shift == null || state.isSubmitting || state.isClockedIn) {
      return;
    }

    emit(state.copyWith(
      isSubmitting: true,
      clearMessage: true,
      clearSuccessTitle: true,
    ));

    try {
      await _shiftRepository.clockIn(shift.id, userId);
      final refreshedLog = await _shiftRepository.getShiftLog(shift.id, userId);

      emit(
        state.copyWith(
          status: ClockStatus.success,
          currentLog: refreshedLog,
          isSubmitting: false,
          successTitle: 'Clock In Successful',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ClockStatus.failure,
          isSubmitting: false,
          message: error.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  void clearMessage() {
    emit(state.copyWith(clearMessage: true));
  }

  void clearSuccessState() {
    emit(state.copyWith(
      status: ClockStatus.ready,
      clearSuccessTitle: true,
    ));
  }

  @override
  Future<void> close() async {
    await _logsSubscription.cancel();
    return super.close();
  }
}
