import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:telme/models/shift_log_model.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/services/shift_repository.dart';

enum ClockStatus { initial, loading, ready, empty, failure }

class ClockState extends Equatable {
  const ClockState({
    this.status = ClockStatus.initial,
    this.currentShift,
    this.currentLog,
    this.isSubmitting = false,
    this.message,
  });

  final ClockStatus status;
  final Shift? currentShift;
  final ShiftLog? currentLog;
  final bool isSubmitting;
  final String? message;

  bool get isClockedIn => currentLog?.clockIn != null;
  bool get isClockedOut => currentLog?.clockOut != null;

  ClockState copyWith({
    ClockStatus? status,
    Shift? currentShift,
    ShiftLog? currentLog,
    bool? isSubmitting,
    String? message,
    bool clearShift = false,
    bool clearLog = false,
    bool clearMessage = false,
  }) {
    return ClockState(
      status: status ?? this.status,
      currentShift: clearShift ? null : (currentShift ?? this.currentShift),
      currentLog: clearLog ? null : (currentLog ?? this.currentLog),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props =>
      [status, currentShift, currentLog, isSubmitting, message];
}

class ClockCubit extends Cubit<ClockState> {
  ClockCubit({
    required ShiftRepository shiftRepository,
    required this.userId,
  })  : _shiftRepository = shiftRepository,
        super(const ClockState(status: ClockStatus.loading));

  final ShiftRepository _shiftRepository;
  final String userId;

  Future<void> load() async {
    emit(state.copyWith(
        status: ClockStatus.loading, isSubmitting: false, clearMessage: true));

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

  Future<void> submitClockAction() async {
    final shift = state.currentShift;
    if (shift == null || state.isSubmitting) {
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearMessage: true));

    try {
      if (state.isClockedIn) {
        await _shiftRepository.clockOut(shift.id, userId);
      } else {
        await _shiftRepository.clockIn(shift.id, userId);
      }

      final successMessage = state.isClockedIn
          ? 'Clocked out successfully.'
          : 'Clocked in successfully.';

      final refreshedShift = await _shiftRepository.getImminentShift(userId);
      if (refreshedShift == null) {
        emit(
          state.copyWith(
            status: ClockStatus.empty,
            isSubmitting: false,
            message: successMessage,
            clearShift: true,
            clearLog: true,
          ),
        );
        return;
      }

      final refreshedLog =
          await _shiftRepository.getShiftLog(refreshedShift.id, userId);

      emit(
        state.copyWith(
          status: ClockStatus.ready,
          currentShift: refreshedShift,
          currentLog: refreshedLog,
          isSubmitting: false,
          message: successMessage,
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
}
