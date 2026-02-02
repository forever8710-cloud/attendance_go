import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/attendance_repository.dart';

enum AttendanceStatus { idle, loading, checkedIn, checkedOut, error }

class AttendanceState {
  const AttendanceState({
    this.status = AttendanceStatus.idle,
    this.todayAttendance,
    this.errorMessage,
  });

  final AttendanceStatus status;
  final Attendance? todayAttendance;
  final String? errorMessage;

  AttendanceState copyWith({
    AttendanceStatus? status,
    Attendance? todayAttendance,
    String? errorMessage,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      todayAttendance: todayAttendance ?? this.todayAttendance,
      errorMessage: errorMessage,
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  AttendanceNotifier(this._repository) : super(const AttendanceState());

  final AttendanceRepository _repository;

  Future<void> loadTodayAttendance(String workerId) async {
    state = state.copyWith(status: AttendanceStatus.loading);
    try {
      final attendance = await _repository.getTodayAttendance(workerId);
      if (attendance != null) {
        final status = attendance.checkOutTime != null
            ? AttendanceStatus.checkedOut
            : AttendanceStatus.checkedIn;
        state = state.copyWith(status: status, todayAttendance: attendance);
      } else {
        state = state.copyWith(status: AttendanceStatus.idle);
      }
    } catch (e) {
      state = state.copyWith(status: AttendanceStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> checkIn(String workerId) async {
    state = state.copyWith(status: AttendanceStatus.loading);
    try {
      // TODO: Get actual GPS coordinates
      final attendance = await _repository.checkIn(workerId, 37.2636, 127.0286);
      state = state.copyWith(status: AttendanceStatus.checkedIn, todayAttendance: attendance);
    } catch (e) {
      state = state.copyWith(status: AttendanceStatus.error, errorMessage: '출근 처리에 실패했습니다');
    }
  }

  Future<void> checkOut() async {
    if (state.todayAttendance == null) return;
    state = state.copyWith(status: AttendanceStatus.loading);
    try {
      final attendance = await _repository.checkOut(
        state.todayAttendance!.id,
        37.2636,
        127.0286,
      );
      state = state.copyWith(status: AttendanceStatus.checkedOut, todayAttendance: attendance);
    } catch (e) {
      state = state.copyWith(status: AttendanceStatus.error, errorMessage: '퇴근 처리에 실패했습니다');
    }
  }
}

final attendanceRepositoryProvider = Provider((ref) => AttendanceRepository());

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier(ref.watch(attendanceRepositoryProvider));
});
