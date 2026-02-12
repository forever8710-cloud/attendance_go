import 'package:supabase_client/supabase_client.dart';

/// 월별 근태 데이터 한 행
class WorkerMonthlyAttendanceRow {
  final DateTime date;
  final String checkIn;
  final String checkOut;
  final String workHours;
  final String status;
  final int remainingLeave;
  final String note;

  const WorkerMonthlyAttendanceRow({
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.workHours,
    required this.status,
    required this.remainingLeave,
    required this.note,
  });
}

/// 월별 근태 요약
class WorkerMonthlySummary {
  final int workDays;
  final double totalWorkHours;
  final int lateDays;
  final int earlyLeaveDays;
  final int absentDays;
  final int remainingLeave;

  const WorkerMonthlySummary({
    required this.workDays,
    required this.totalWorkHours,
    required this.lateDays,
    required this.earlyLeaveDays,
    required this.absentDays,
    required this.remainingLeave,
  });
}

class WorkerDetailRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  /// 해당 월의 일별 근태 데이터 조회
  Future<List<WorkerMonthlyAttendanceRow>> getMonthlyAttendance(
    String workerId,
    String yearMonth,
  ) async {
    final parts = yearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final start = DateTime(year, month, 1).toUtc().toIso8601String();
    final end = DateTime(year, month + 1, 1).toUtc().toIso8601String();

    // Supabase에서 해당 월 출퇴근 기록 조회
    final attendances = await _supabase
        .from('attendances')
        .select()
        .eq('worker_id', workerId)
        .gte('check_in_time', start)
        .lt('check_in_time', end)
        .order('check_in_time', ascending: true);

    // 날짜별 매핑
    final attByDate = <String, Map<String, dynamic>>{};
    for (final att in attendances) {
      final ciTime = DateTime.parse(att['check_in_time'] as String).toLocal();
      final dateKey = '${ciTime.year}-${ciTime.month.toString().padLeft(2, '0')}-${ciTime.day.toString().padLeft(2, '0')}';
      attByDate[dateKey] = att;
    }

    int remainingLeave = 15;
    final rows = <WorkerMonthlyAttendanceRow>[];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final weekday = date.weekday;

      if (weekday == 6 || weekday == 7) {
        rows.add(WorkerMonthlyAttendanceRow(
          date: date,
          checkIn: '-',
          checkOut: '-',
          workHours: '-',
          status: '휴일',
          remainingLeave: remainingLeave,
          note: weekday == 6 ? '토요일' : '일요일',
        ));
        continue;
      }

      // 미래 날짜
      if (date.isAfter(DateTime.now())) {
        rows.add(WorkerMonthlyAttendanceRow(
          date: date,
          checkIn: '-',
          checkOut: '-',
          workHours: '-',
          status: '-',
          remainingLeave: remainingLeave,
          note: '',
        ));
        continue;
      }

      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final att = attByDate[dateKey];

      if (att == null) {
        rows.add(WorkerMonthlyAttendanceRow(
          date: date,
          checkIn: '-',
          checkOut: '-',
          workHours: '-',
          status: '미출근',
          remainingLeave: remainingLeave,
          note: '',
        ));
        continue;
      }

      final ciTime = DateTime.parse(att['check_in_time'] as String).toLocal();
      final checkIn = '${ciTime.hour.toString().padLeft(2, '0')}:${ciTime.minute.toString().padLeft(2, '0')}';

      String checkOut = '-';
      String workHoursStr = '-';
      String status = '출근';
      String note = '';

      if (att['check_out_time'] != null) {
        final coTime = DateTime.parse(att['check_out_time'] as String).toLocal();
        checkOut = '${coTime.hour.toString().padLeft(2, '0')}:${coTime.minute.toString().padLeft(2, '0')}';

        final wh = att['work_hours'];
        if (wh != null) {
          final hours = (wh is num) ? wh.toDouble() : double.tryParse(wh.toString()) ?? 0;
          final h = hours.toInt();
          final m = ((hours - h) * 60).round();
          workHoursStr = '${h}h ${m}m';
        }

        if (coTime.hour < 16) {
          status = '조퇴';
          note = '조퇴';
        }
      }

      // 지각: 09:00 이후 출근
      if (ciTime.hour >= 9 && ciTime.minute > 0 && status == '출근') {
        status = '지각';
        note = '지각';
      }

      rows.add(WorkerMonthlyAttendanceRow(
        date: date,
        checkIn: checkIn,
        checkOut: checkOut,
        workHours: workHoursStr,
        status: status,
        remainingLeave: remainingLeave,
        note: note,
      ));
    }

    return rows;
  }

  /// 월별 요약 계산
  Future<WorkerMonthlySummary> getMonthlySummary(
    String workerId,
    String yearMonth,
  ) async {
    final rows = await getMonthlyAttendance(workerId, yearMonth);

    int workDays = 0;
    double totalWorkHours = 0;
    int lateDays = 0;
    int earlyLeaveDays = 0;
    int absentDays = 0;
    int remainingLeave = 15;

    for (final row in rows) {
      if (row.status == '휴일' || row.status == '-') continue;
      if (row.status == '출근') workDays++;
      if (row.status == '지각') { workDays++; lateDays++; }
      if (row.status == '조퇴') { workDays++; earlyLeaveDays++; }
      if (row.status == '미출근') absentDays++;
      if (row.status == '연차') remainingLeave--;

      // 근무시간 합산
      if (row.workHours != '-') {
        final match = RegExp(r'(\d+)h\s*(\d+)m').firstMatch(row.workHours);
        if (match != null) {
          final h = int.parse(match.group(1)!);
          final m = int.parse(match.group(2)!);
          totalWorkHours += h + m / 60.0;
        }
      }
    }

    return WorkerMonthlySummary(
      workDays: workDays,
      totalWorkHours: totalWorkHours,
      lateDays: lateDays,
      earlyLeaveDays: earlyLeaveDays,
      absentDays: absentDays,
      remainingLeave: remainingLeave,
    );
  }
}
