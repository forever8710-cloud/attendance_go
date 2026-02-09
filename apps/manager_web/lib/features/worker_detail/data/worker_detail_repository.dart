import 'dart:math';

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
  final int lateDays;
  final int earlyLeaveDays;
  final int absentDays;
  final int remainingLeave;

  const WorkerMonthlySummary({
    required this.workDays,
    required this.lateDays,
    required this.earlyLeaveDays,
    required this.absentDays,
    required this.remainingLeave,
  });
}

class WorkerDetailRepository {
  /// 해당 월의 일별 근태 데모 데이터 생성
  Future<List<WorkerMonthlyAttendanceRow>> getMonthlyAttendance(
    String workerName,
    String yearMonth,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final parts = yearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final seed = workerName.hashCode ^ (year * 100 + month);
    final rng = Random(seed);

    int remainingLeave = 15;
    final rows = <WorkerMonthlyAttendanceRow>[];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final weekday = date.weekday; // 6=토, 7=일

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

      // 평일: 확률 기반 상태 결정
      final roll = rng.nextDouble();
      String status;
      String checkIn;
      String checkOut;
      String workHours;
      String note = '';

      if (roll < 0.02 && remainingLeave > 0) {
        // 2% 연차
        status = '연차';
        checkIn = '-';
        checkOut = '-';
        workHours = '-';
        note = '연차 사용';
        remainingLeave--;
      } else if (roll < 0.07) {
        // 5% 미출근
        status = '미출근';
        checkIn = '-';
        checkOut = '-';
        workHours = '-';
        note = '';
      } else if (roll < 0.10) {
        // 3% 조퇴
        status = '조퇴';
        final hour = 8 + rng.nextInt(1); // 08 or 08
        final minute = rng.nextInt(60);
        checkIn = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        final leaveHour = 14 + rng.nextInt(3); // 14~16시
        final leaveMinute = rng.nextInt(60);
        checkOut = '${leaveHour.toString().padLeft(2, '0')}:${leaveMinute.toString().padLeft(2, '0')}';
        final totalMin = (leaveHour - hour) * 60 + (leaveMinute - minute);
        final h = totalMin ~/ 60;
        final m = totalMin % 60;
        workHours = '${h}h ${m.abs()}m';
        note = '조퇴';
      } else if (roll < 0.15) {
        // 5% 지각
        status = '지각';
        final hour = 9 + rng.nextInt(2); // 09~10시
        final minute = rng.nextInt(60);
        checkIn = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        checkOut = '18:00';
        final totalMin = (18 - hour) * 60 - minute;
        final h = totalMin ~/ 60;
        final m = totalMin % 60;
        workHours = '${h}h ${m}m';
        note = '지각';
      } else {
        // 85% 정상 출근
        status = '출근';
        final minute = rng.nextInt(30); // 08:00~08:29
        checkIn = '08:${minute.toString().padLeft(2, '0')}';
        checkOut = '18:00';
        final totalMin = (18 - 8) * 60 - minute;
        final h = totalMin ~/ 60;
        final m = totalMin % 60;
        workHours = '${h}h ${m}m';
        note = '';
      }

      // 미래 날짜면 데이터 없음
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

      rows.add(WorkerMonthlyAttendanceRow(
        date: date,
        checkIn: checkIn,
        checkOut: checkOut,
        workHours: workHours,
        status: status,
        remainingLeave: remainingLeave,
        note: note,
      ));
    }

    return rows;
  }

  /// 월별 요약 계산
  Future<WorkerMonthlySummary> getMonthlySummary(
    String workerName,
    String yearMonth,
  ) async {
    final rows = await getMonthlyAttendance(workerName, yearMonth);

    int workDays = 0;
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
    }

    return WorkerMonthlySummary(
      workDays: workDays,
      lateDays: lateDays,
      earlyLeaveDays: earlyLeaveDays,
      absentDays: absentDays,
      remainingLeave: remainingLeave,
    );
  }
}
