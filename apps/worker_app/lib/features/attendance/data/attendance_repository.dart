import 'package:core/core.dart';

class AttendanceRepository {
  Attendance? _todayAttendance;

  Future<Attendance?> getTodayAttendance(String workerId) async {
    // TODO: Query Supabase for today's attendance
    await Future.delayed(const Duration(milliseconds: 300));
    return _todayAttendance;
  }

  Future<Attendance> checkIn(String workerId, double lat, double lng) async {
    // TODO: Insert into Supabase attendances table
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();
    final attendance = Attendance(
      id: 'att-${now.millisecondsSinceEpoch}',
      workerId: workerId,
      checkInTime: now,
      checkInLatitude: lat,
      checkInLongitude: lng,
      status: 'present',
    );
    _todayAttendance = attendance;
    return attendance;
  }

  Future<Attendance> checkOut(String attendanceId, double lat, double lng) async {
    // TODO: Update Supabase attendance record
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();
    final updated = _todayAttendance!.copyWith(
      checkOutTime: now,
      checkOutLatitude: lat,
      checkOutLongitude: lng,
      workHours: now.difference(_todayAttendance!.checkInTime).inMinutes / 60.0,
    );
    _todayAttendance = updated;
    return updated;
  }

  Future<List<Attendance>> getMonthlyAttendances(String workerId, int year, int month) async {
    // TODO: Query Supabase
    await Future.delayed(const Duration(milliseconds: 500));
    // Return demo data
    final List<Attendance> records = [];
    final daysInMonth = DateTime(year, month + 1, 0).day;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) continue;
      if (date.isAfter(DateTime.now())) continue;
      records.add(Attendance(
        id: 'att-$year$month$day',
        workerId: workerId,
        checkInTime: DateTime(year, month, day, 8, 50),
        checkInLatitude: 37.2636,
        checkInLongitude: 127.0286,
        checkOutTime: DateTime(year, month, day, 18, 10),
        checkOutLatitude: 37.2636,
        checkOutLongitude: 127.0286,
        workHours: 9.33,
        status: 'present',
      ));
    }
    return records;
  }
}
