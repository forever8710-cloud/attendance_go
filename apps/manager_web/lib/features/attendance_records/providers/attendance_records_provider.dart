import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/attendance_records_repository.dart';

final attendanceRecordsRepositoryProvider =
    Provider((ref) => AttendanceRecordsRepository());

/// 날짜 범위 (기본: 오늘)
final attendanceDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return DateTimeRange(start: today, end: today);
});

/// 근태 기록 목록 (날짜 범위에 따라 재조회)
final attendanceRecordsProvider =
    FutureProvider<List<AttendanceRecordRow>>((ref) {
  final range = ref.watch(attendanceDateRangeProvider);
  final repo = ref.watch(attendanceRecordsRepositoryProvider);
  return repo.getAttendances(range.start, range.end);
});
