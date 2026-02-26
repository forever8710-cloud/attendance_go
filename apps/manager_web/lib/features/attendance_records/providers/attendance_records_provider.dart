import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/permissions.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/attendance_records_repository.dart';

final attendanceRecordsRepositoryProvider =
    Provider((ref) => AttendanceRecordsRepository());

/// 날짜 범위 (기본: 오늘)
final attendanceDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return DateTimeRange(start: today, end: today);
});

/// system_admin / owner → 전체 (siteId='')
/// center_manager → 자기 사이트만
String _effectiveSiteId(Ref ref) {
  final authState = ref.watch(authProvider);
  if (canAccessAllSites(authState.role)) return '';
  return authState.worker?.siteId ?? '';
}

/// 근태 기록 목록 (날짜 범위 + 사이트 필터에 따라 재조회)
final attendanceRecordsProvider =
    FutureProvider<List<AttendanceRecordRow>>((ref) {
  final range = ref.watch(attendanceDateRangeProvider);
  final siteId = _effectiveSiteId(ref);
  final repo = ref.watch(attendanceRecordsRepositoryProvider);
  return repo.getAttendances(
    range.start,
    range.end,
    siteId: siteId.isEmpty ? null : siteId,
  );
});
