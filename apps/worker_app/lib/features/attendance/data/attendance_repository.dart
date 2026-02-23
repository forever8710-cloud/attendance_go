import 'package:core/core.dart';
import 'package:supabase_client/supabase_client.dart';

class AttendanceRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<Attendance?> getTodayAttendance(String workerId) async {
    // KST 기준 "오늘"의 시작/끝을 UTC로 변환 (KST = UTC+9)
    final now = DateTime.now();
    final localToday = DateTime(now.year, now.month, now.day); // 로컬 자정
    final todayStart = localToday.toUtc().toIso8601String();
    final tomorrowStart = localToday.add(const Duration(days: 1)).toUtc().toIso8601String();

    final rows = await _supabase
        .from('attendances')
        .select()
        .eq('worker_id', workerId)
        .gte('check_in_time', todayStart)
        .lt('check_in_time', tomorrowStart)
        .order('check_in_time', ascending: false)
        .limit(1);

    if (rows.isEmpty) return null;
    return Attendance.fromJson(rows.first);
  }

  Future<Attendance> checkIn(String workerId, double lat, double lng) async {
    final now = DateTime.now().toUtc().toIso8601String();

    final row = await _supabase
        .from('attendances')
        .insert({
          'worker_id': workerId,
          'check_in_time': now,
          'check_in_latitude': lat,
          'check_in_longitude': lng,
          'status': 'present',
        })
        .select()
        .single();

    return Attendance.fromJson(row);
  }

  Future<Attendance> checkOut(String attendanceId, double lat, double lng) async {
    final now = DateTime.now().toUtc().toIso8601String();

    // work_hours는 DB trigger가 자동 계산
    final row = await _supabase
        .from('attendances')
        .update({
          'check_out_time': now,
          'check_out_latitude': lat,
          'check_out_longitude': lng,
        })
        .eq('id', attendanceId)
        .select()
        .single();

    return Attendance.fromJson(row);
  }

  Future<Attendance> earlyLeaveCheckOut(
    String attendanceId,
    double lat,
    double lng,
    String reason,
  ) async {
    final now = DateTime.now().toUtc().toIso8601String();

    final row = await _supabase
        .from('attendances')
        .update({
          'check_out_time': now,
          'check_out_latitude': lat,
          'check_out_longitude': lng,
          'status': 'leave',
          'notes': reason,
        })
        .eq('id', attendanceId)
        .select()
        .single();

    return Attendance.fromJson(row);
  }

  /// 근로자의 소속 사업장 좌표/반경 조회
  Future<Map<String, dynamic>?> getWorkerSite(String workerId) async {
    final workerRows = await _supabase
        .from('workers')
        .select('site_id')
        .eq('id', workerId)
        .limit(1);

    if (workerRows.isEmpty) return null;
    final siteId = workerRows.first['site_id'] as String?;
    if (siteId == null || siteId.isEmpty) return null;

    final siteRows = await _supabase
        .from('sites')
        .select('latitude, longitude, radius, name')
        .eq('id', siteId)
        .limit(1);

    if (siteRows.isEmpty) return null;
    return siteRows.first;
  }

  Future<List<Attendance>> getMonthlyAttendances(String workerId, int year, int month) async {
    // 로컬 시간 기준 월의 시작/끝을 UTC로 변환
    final start = DateTime(year, month, 1).toUtc().toIso8601String();
    final end = DateTime(year, month + 1, 1).toUtc().toIso8601String();

    final rows = await _supabase
        .from('attendances')
        .select()
        .eq('worker_id', workerId)
        .gte('check_in_time', start)
        .lt('check_in_time', end)
        .order('check_in_time', ascending: true);

    return (rows as List).map((r) => Attendance.fromJson(r)).toList();
  }
}
