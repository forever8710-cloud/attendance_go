import 'dart:async';
import 'dart:math' as math;
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/tts_service.dart';
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
      // 권한 확인 실패 시 바로 요청 시도
      permission = LocationPermission.denied;
    }

    if (permission == LocationPermission.denied) {
      try {
        permission = await Geolocator.requestPermission();
      } catch (_) {
        throw Exception(
          '[OPEN_SETTINGS]위치 권한을 요청할 수 없습니다.\n'
          '아래 버튼을 눌러 위치 권한을 허용해주세요.',
        );
      }
      if (permission == LocationPermission.denied) {
        throw Exception(
          '[OPEN_SETTINGS]위치 권한이 거부되었습니다.\n'
          '아래 버튼을 눌러 위치 권한을 허용해주세요.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        '[OPEN_SETTINGS]위치 권한이 영구 거부되었습니다.\n'
        '아래 버튼을 눌러 위치 권한을 허용해주세요.',
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

      // 4. 위치 정확도 검증 (50m 이상이면 경고)
      if (position.accuracy > 50) {
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
    // 중복 출근 방지: 이미 출근 상태이면 무시
    if (state.status == AttendanceStatus.checkedIn && state.todayAttendance != null) {
      state = state.copyWith(errorMessage: '이미 출근했습니다.');
      return;
    }
    state = state.copyWith(status: AttendanceStatus.loading);
    try {
      // DB에서도 당일 출근 기록 재확인
      final existing = await _repository.getTodayAttendance(workerId);
      if (existing != null) {
        final status = existing.checkOutTime != null
            ? AttendanceStatus.checkedOut
            : AttendanceStatus.checkedIn;
        state = state.copyWith(status: status, todayAttendance: existing,
            errorMessage: status == AttendanceStatus.checkedIn ? '이미 출근했습니다.' : '이미 퇴근 처리되었습니다.');
        return;
      }
      final position = await _getCurrentPosition();
      await _validateSiteProximity(position, workerId);
      final attendance = await _repository.checkIn(
        workerId,
        position.latitude,
        position.longitude,
      );
      state = state.copyWith(
          status: AttendanceStatus.checkedIn, todayAttendance: attendance);
      TtsService.speak('출근완료');
    } catch (e) {
      // DB unique constraint 위반 (동시 요청) → 기존 기록 복원
      final msg = e.toString();
      if (msg.contains('duplicate') || msg.contains('unique') || msg.contains('23505')) {
        final existing = await _repository.getTodayAttendance(workerId);
        if (existing != null) {
          state = state.copyWith(
            status: AttendanceStatus.checkedIn,
            todayAttendance: existing,
            errorMessage: '이미 출근 처리되었습니다.',
          );
          return;
        }
      }
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
      await _validateSiteProximity(position, state.todayAttendance!.workerId);
      final attendance = await _repository.checkOut(
        state.todayAttendance!.id,
        position.latitude,
        position.longitude,
      );
      state = state.copyWith(
          status: AttendanceStatus.checkedOut, todayAttendance: attendance);
      TtsService.speak('퇴근완료');
    } catch (e) {
      // 퇴근 실패 시 이전 상태(checkedIn)로 복원
      state = state.copyWith(
        status: AttendanceStatus.checkedIn,
        errorMessage: _friendlyError(e),
      );
    }
  }

  Future<void> earlyLeave(String reason) async {
    if (state.todayAttendance == null) return;
    state = state.copyWith(status: AttendanceStatus.loading);
    try {
      final position = await _getCurrentPosition();
      await _validateSiteProximity(position, state.todayAttendance!.workerId);
      final attendance = await _repository.earlyLeaveCheckOut(
        state.todayAttendance!.id,
        position.latitude,
        position.longitude,
        reason,
      );
      state = state.copyWith(
          status: AttendanceStatus.checkedOut, todayAttendance: attendance);
      TtsService.speak('퇴근완료');
    } catch (e) {
      state = state.copyWith(
        status: AttendanceStatus.checkedIn,
        errorMessage: _friendlyError(e),
      );
    }
  }

  /// 사업장 반경 검증 (Haversine 공식)
  Future<void> _validateSiteProximity(Position position, String workerId) async {
    final site = await _repository.getWorkerSite(workerId);
    if (site == null) {
      throw Exception(
        '배정된 사업장이 없습니다.\n'
        '관리자에게 사업장 배정을 요청해주세요.',
      );
    }

    final siteLat = double.tryParse(site['latitude'].toString()) ?? 0;
    final siteLng = double.tryParse(site['longitude'].toString()) ?? 0;
    final radius = (site['radius'] as int?) ?? 100;
    final siteName = site['name'] as String? ?? '사업장';

    if (siteLat == 0 && siteLng == 0) return; // 좌표 미설정이면 스킵

    final distance = _haversineDistance(
      position.latitude, position.longitude, siteLat, siteLng,
    );

    if (distance > radius) {
      throw Exception(
        '$siteName 반경 ${radius}m 밖에 있습니다.\n'
        '현재 거리: ${distance.toInt()}m\n'
        '사업장 근처에서 다시 시도해주세요.',
      );
    }
  }

  /// Haversine 공식으로 두 좌표 간 거리(m) 계산
  double _haversineDistance(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371000.0; // 지구 반지름 (m)
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

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
