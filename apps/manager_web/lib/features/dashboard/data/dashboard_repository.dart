import 'package:supabase_client/supabase_client.dart';

class DashboardRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  /// 근태 판정 시간 경계값
  static const int kLateHour = 9;         // 지각 기준: 09:00 이후 출근
  static const int kEarlyLeaveHour = 16;  // 조퇴 기준: 16:00 이전 퇴근

  /// site_id → name 매핑 캐시
  Map<String, String> _siteNames = {};
  Map<String, String> _partNames = {};

  Future<void> _loadMappings() async {
    if (_siteNames.isNotEmpty) return;
    try {
      final sites = await _supabase.from('sites').select('id, name');
      _siteNames = {for (final s in sites) s['id'] as String: s['name'] as String};
      final parts = await _supabase.from('parts').select('id, name');
      _partNames = {for (final p in parts) p['id'] as String: p['name'] as String};
    } catch (_) {
      // 매핑 로드 실패 시 빈 매핑으로 유지
    }
  }

  Future<DashboardSummary> getTodaySummary(String siteId) async {
    await _loadMappings();

    // 전체 활성 근로자 수 (센터장은 본인 센터만)
    var workersQuery = _supabase
        .from('workers')
        .select('id, part_id')
        .eq('is_active', true)
        .eq('role', 'worker');

    if (siteId.isNotEmpty) {
      workersQuery = workersQuery.eq('site_id', siteId);
    }

    final allWorkers = await workersQuery;
    final totalWorkers = allWorkers.length;

    // 오늘 출근 기록
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).toUtc().toIso8601String();
    final tomorrowStart = DateTime(now.year, now.month, now.day + 1).toUtc().toIso8601String();

    var attQuery = _supabase
        .from('attendances')
        .select('*, workers!inner(part_id, site_id)')
        .gte('check_in_time', todayStart)
        .lt('check_in_time', tomorrowStart);

    if (siteId.isNotEmpty) {
      attQuery = attQuery.eq('workers.site_id', siteId);
    }

    final attendances = await attQuery;

    int dayCheckedIn = 0;
    int nightCheckedIn = 0;
    int checkedOut = 0;
    int late = 0;
    int earlyLeave = 0;

    for (final att in attendances) {
      final worker = att['workers'] as Map<String, dynamic>?;
      final partId = worker?['part_id'] as String?;
      final partName = partId != null ? (_partNames[partId] ?? '') : '';
      final isNight = partName.contains('야간');
      final checkInTime = DateTime.parse(att['check_in_time'] as String).toLocal();

      if (isNight) {
        nightCheckedIn++;
      } else {
        dayCheckedIn++;
      }

      if (att['check_out_time'] != null) {
        checkedOut++;
        final checkOutTime = DateTime.parse(att['check_out_time'] as String).toLocal();
        // 16시 전 퇴근 = 조퇴
        if (!isNight && checkOutTime.hour < kEarlyLeaveHour) {
          earlyLeave++;
        }
      }

      // 9시 이후 출근 = 지각 (야간 제외)
      if (!isNight && checkInTime.hour >= kLateHour && checkInTime.minute > 0) {
        late++;
      }
    }

    final checkedInWorkerIds = attendances.map((a) => a['worker_id']).toSet();
    final absent = totalWorkers - checkedInWorkerIds.length;

    return DashboardSummary(
      totalWorkers: totalWorkers,
      dayCheckedIn: dayCheckedIn,
      nightCheckedIn: nightCheckedIn,
      checkedOut: checkedOut,
      late: late,
      earlyLeave: earlyLeave,
      absent: absent < 0 ? 0 : absent,
    );
  }

  Future<List<WorkerAttendanceRow>> getTodayAttendances(String siteId) async {
    await _loadMappings();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).toUtc().toIso8601String();
    final tomorrowStart = DateTime(now.year, now.month, now.day + 1).toUtc().toIso8601String();

    // 전체 활성 근로자 목록 (센터장은 본인 센터만)
    var workersQuery = _supabase
        .from('workers')
        .select('id, name, phone, site_id, part_id, worker_profiles(position, job)')
        .eq('is_active', true)
        .eq('role', 'worker');

    if (siteId.isNotEmpty) {
      workersQuery = workersQuery.eq('site_id', siteId);
    }

    final allWorkers = await workersQuery;

    // 오늘 출근 기록
    final attendances = await _supabase
        .from('attendances')
        .select()
        .gte('check_in_time', todayStart)
        .lt('check_in_time', tomorrowStart);

    // worker_id → attendance 매핑
    final attMap = <String, Map<String, dynamic>>{};
    for (final att in attendances) {
      attMap[att['worker_id'] as String] = att;
    }

    final rows = <WorkerAttendanceRow>[];

    for (final w in allWorkers) {
      final wId = w['id'] as String;
      final siteId = w['site_id'] as String?;
      final partId = w['part_id'] as String?;
      final siteName = siteId != null ? (_siteNames[siteId] ?? '') : '';
      final partName = partId != null ? (_partNames[partId] ?? '') : '';

      final profiles = w['worker_profiles'];
      final profile = (profiles is List && profiles.isNotEmpty) ? profiles.first : null;
      final position = (profile?['position'] as String?) ?? '';
      final job = (profile?['job'] as String?) ?? partName;

      final att = attMap[wId];
      final isNight = job.contains('야간') || partName.contains('야간');

      String checkIn = '-';
      String checkOut = '-';
      String workHours = '-';
      String status = '미출근';
      String note = '';

      if (att != null) {
        final ciTime = DateTime.parse(att['check_in_time'] as String).toLocal();
        checkIn = '${ciTime.hour.toString().padLeft(2, '0')}:${ciTime.minute.toString().padLeft(2, '0')}';

        if (att['check_out_time'] != null) {
          final coTime = DateTime.parse(att['check_out_time'] as String).toLocal();
          checkOut = '${coTime.hour.toString().padLeft(2, '0')}:${coTime.minute.toString().padLeft(2, '0')}';

          final wh = att['work_hours'];
          if (wh != null) {
            final hours = (wh is num) ? wh.toDouble() : double.tryParse(wh.toString()) ?? 0;
            final h = hours.toInt();
            final m = ((hours - h) * 60).round();
            workHours = '${h}h ${m}m';
          }

          // 조퇴 판단: 16시 전 퇴근
          if (!isNight && coTime.hour < kEarlyLeaveHour) {
            status = '조퇴';
            note = '조퇴';
          } else {
            status = '출근';
          }
        } else {
          status = '출근';
        }

        // 지각 판단: 09:00 이후 출근 (야간 제외)
        if (!isNight && ciTime.hour >= kLateHour && ciTime.minute > 0 && status == '출근') {
          status = '지각';
          note = '지각';
        }

        if (isNight) {
          note = '야간근무';
        }
      }

      rows.add(WorkerAttendanceRow(
        id: wId,
        name: w['name'] as String,
        position: position,
        job: job,
        site: siteName,
        phone: w['phone'] as String,
        checkIn: checkIn,
        checkOut: checkOut,
        workHours: workHours,
        status: status,
        note: note,
      ));
    }

    // 출근자를 먼저, 미출근자를 뒤로
    rows.sort((a, b) {
      if (a.status == '미출근' && b.status != '미출근') return 1;
      if (a.status != '미출근' && b.status == '미출근') return -1;
      return a.name.compareTo(b.name);
    });

    return rows;
  }

  /// 최근 N일간 일별 출근 통계
  Future<List<DailyAttendanceStat>> getWeeklyTrend(String siteId, {int days = 7}) async {
    await _loadMappings();

    final now = DateTime.now();
    final stats = <DailyAttendanceStat>[];

    // 전체 활성 근로자 수 (센터장은 본인 센터만)
    var workersQuery = _supabase
        .from('workers')
        .select('id')
        .eq('is_active', true)
        .eq('role', 'worker');

    if (siteId.isNotEmpty) {
      workersQuery = workersQuery.eq('site_id', siteId);
    }

    final allWorkers = await workersQuery;
    final totalWorkers = allWorkers.length;

    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dayStart = date.toUtc().toIso8601String();
      final dayEnd = DateTime(date.year, date.month, date.day + 1).toUtc().toIso8601String();

      var attQuery = _supabase
          .from('attendances')
          .select('*, workers!inner(part_id, site_id)')
          .gte('check_in_time', dayStart)
          .lt('check_in_time', dayEnd);

      if (siteId.isNotEmpty) {
        attQuery = attQuery.eq('workers.site_id', siteId);
      }

      final attendances = await attQuery;

      int present = 0;
      int lateCount = 0;
      int earlyLeaveCount = 0;

      final checkedWorkerIds = <String>{};

      for (final att in attendances) {
        checkedWorkerIds.add(att['worker_id'] as String);
        final worker = att['workers'] as Map<String, dynamic>?;
        final partId = worker?['part_id'] as String?;
        final partName = partId != null ? (_partNames[partId] ?? '') : '';
        final isNight = partName.contains('야간');
        final checkInTime = DateTime.parse(att['check_in_time'] as String).toLocal();

        present++;

        if (!isNight && checkInTime.hour >= kLateHour && checkInTime.minute > 0) {
          lateCount++;
        }

        if (att['check_out_time'] != null) {
          final checkOutTime = DateTime.parse(att['check_out_time'] as String).toLocal();
          if (!isNight && checkOutTime.hour < kEarlyLeaveHour) {
            earlyLeaveCount++;
          }
        }
      }

      final absent = totalWorkers - checkedWorkerIds.length;

      stats.add(DailyAttendanceStat(
        date: date,
        totalWorkers: totalWorkers,
        presentCount: present,
        lateCount: lateCount,
        earlyLeaveCount: earlyLeaveCount,
        absentCount: absent < 0 ? 0 : absent,
      ));
    }

    return stats;
  }

  /// 사이트 목록 조회
  Future<List<Map<String, String>>> getSites() async {
    final sites = await _supabase.from('sites').select('id, name');
    return (sites as List)
        .map((s) => {'id': s['id'] as String, 'name': s['name'] as String})
        .toList();
  }
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalWorkers,
    required this.dayCheckedIn,
    required this.nightCheckedIn,
    required this.checkedOut,
    required this.late,
    this.earlyLeave,
    required this.absent,
  });
  final int totalWorkers;
  final int dayCheckedIn;
  final int nightCheckedIn;
  final int checkedOut;
  final int late;
  final int? earlyLeave;
  final int absent;
}

class DailyAttendanceStat {
  const DailyAttendanceStat({
    required this.date,
    required this.totalWorkers,
    required this.presentCount,
    required this.lateCount,
    required this.earlyLeaveCount,
    required this.absentCount,
  });
  final DateTime date;
  final int totalWorkers;
  final int presentCount;
  final int lateCount;
  final int earlyLeaveCount;
  final int absentCount;

  double get attendanceRate =>
      totalWorkers > 0 ? (presentCount / totalWorkers * 100) : 0;
}

class WorkerAttendanceRow {
  const WorkerAttendanceRow({
    this.id,
    required this.name,
    required this.position,
    required this.job,
    required this.site,
    required this.phone,
    required this.checkIn,
    required this.checkOut,
    required this.workHours,
    required this.status,
    required this.note,
  });
  final String? id;
  final String name;
  final String position;
  final String job;
  final String site;
  final String phone;
  final String checkIn;
  final String checkOut;
  final String workHours;
  final String status;
  final String note;
}
