import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
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

  /// GPS 위치 가져오기
  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스가 꺼져 있습니다. 설정에서 활성화해주세요.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<void> checkIn(String workerId) async {
    state = state.copyWith(status: AttendanceStatus.loading);
    try {
      final position = await _getCurrentPosition();
      final attendance = await _repository.checkIn(
        workerId,
        position.latitude,
        position.longitude,
      );
      state = state.copyWith(status: AttendanceStatus.checkedIn, todayAttendance: attendance);
    } catch (e) {
      state = state.copyWith(status: AttendanceStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> checkOut() async {
    if (state.todayAttendance == null) return;
    state = state.copyWith(status: AttendanceStatus.loading);
    try {
      final position = await _getCurrentPosition();
      final attendance = await _repository.checkOut(
        state.todayAttendance!.id,
        position.latitude,
        position.longitude,
      );
      state = state.copyWith(status: AttendanceStatus.checkedOut, todayAttendance: attendance);
    } catch (e) {
      state = state.copyWith(status: AttendanceStatus.error, errorMessage: e.toString());
    }
  }
}

final attendanceRepositoryProvider = Provider((ref) => AttendanceRepository());

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier(ref.watch(attendanceRepositoryProvider));
});
