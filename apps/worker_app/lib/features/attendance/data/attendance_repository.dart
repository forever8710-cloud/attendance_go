import 'package:core/core.dart';
import 'package:supabase_client/supabase_client.dart';

class AttendanceRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<Attendance?> getTodayAttendance(String workerId) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).toUtc().toIso8601String();
    final tomorrowStart = DateTime(now.year, now.month, now.day + 1).toUtc().toIso8601String();

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

  Future<List<Attendance>> getMonthlyAttendances(String workerId, int year, int month) async {
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
