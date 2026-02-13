import 'dart:async';
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
      state = state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: _friendlyError(e),
      );
    }
  }

  /// GPS 위치 가져오기 (타임아웃 + 정확도 검증)
  Future<Position> _getCurrentPosition() async {
    // 1. 위치 서비스 활성화 확인
    bool serviceEnabled;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      throw Exception('위치 서비스 상태를 확인할 수 없습니다.');
    }

    if (!serviceEnabled) {
      throw Exception(
        '위치 서비스가 꺼져 있습니다.\n'
        '기기 설정 > 위치에서 GPS를 활성화해주세요.',
      );
    }

    // 2. 위치 권한 확인 / 요청
    LocationPermission permission;
    try {
      permission = await Geolocator.checkPermission();
    } catch (_) {
      throw Exception('위치 권한 상태를 확인할 수 없습니다.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          '위치 권한이 거부되었습니다.\n'
          '출퇴근 기록을 위해 위치 권한을 허용해주세요.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        '위치 권한이 영구 거부되었습니다.\n'
        '기기 설정 > 앱 > WorkFlow > 권한에서\n'
        '위치 권한을 허용해주세요.',
      );
    }

    // 3. GPS 위치 수신 (15초 타임아웃)
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // 4. 위치 정확도 검증 (500m 이상이면 경고)
      if (position.accuracy > 500) {
        throw Exception(
          'GPS 정확도가 낮습니다 (${position.accuracy.toInt()}m).\n'
          '실외로 이동하거나 잠시 후 다시 시도해주세요.',
        );
      }

      return position;
    } on TimeoutException {
      throw Exception(
        'GPS 신호를 받지 못했습니다.\n'
        '실외에서 하늘이 보이는 곳으로 이동 후\n'
        '다시 시도해주세요.',
      );
    }
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
      state = state.copyWith(
          status: AttendanceStatus.checkedIn, todayAttendance: attendance);
    } catch (e) {
      state = state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: _friendlyError(e),
      );
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
      state = state.copyWith(
          status: AttendanceStatus.checkedOut, todayAttendance: attendance);
    } catch (e) {
      // 퇴근 실패 시 이전 상태(checkedIn)로 복원
      state = state.copyWith(
        status: AttendanceStatus.checkedIn,
        errorMessage: _friendlyError(e),
      );
    }
  }

  /// 에러 메시지를 사용자 친화적으로 변환
  String _friendlyError(Object e) {
    final msg = e.toString();
    // Exception: prefix 제거
    if (msg.startsWith('Exception: ')) {
      return msg.substring(11);
    }
    // 네트워크 에러
    if (msg.contains('SocketException') || msg.contains('ClientException')) {
      return '네트워크 연결을 확인해주세요.';
    }
    // Supabase 에러
    if (msg.contains('PostgrestException')) {
      return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
    return '오류가 발생했습니다. 다시 시도해주세요.';
  }
}

final attendanceRepositoryProvider = Provider((ref) => AttendanceRepository());

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier(ref.watch(attendanceRepositoryProvider));
});
