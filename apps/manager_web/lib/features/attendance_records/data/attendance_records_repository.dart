import 'package:supabase_client/supabase_client.dart';

class AttendanceRecordsRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Map<String, String> _siteNames = {};
  Map<String, String> _partNames = {};

  Future<void> _loadMappings() async {
    if (_siteNames.isNotEmpty) return;
    final sites = await _supabase.from('sites').select('id, name');
    _siteNames = {for (final s in sites) s['id'] as String: s['name'] as String};
    final parts = await _supabase.from('parts').select('id, name');
    _partNames = {for (final p in parts) p['id'] as String: p['name'] as String};
  }

  Future<List<AttendanceRecordRow>> getAttendances(
    DateTime startDate,
    DateTime endDate, {
    String? siteId,
  }) async {
    await _loadMappings();

    final start = DateTime(startDate.year, startDate.month, startDate.day).toUtc().toIso8601String();
    final end = DateTime(endDate.year, endDate.month, endDate.day + 1).toUtc().toIso8601String();

    final attendances = await _supabase
        .from('attendances')
        .select('*, workers!inner(name, phone, site_id, part_id, worker_profiles(position, job))')
        .gte('check_in_time', start)
        .lt('check_in_time', end)
        .neq('status', 'deleted')
        .order('check_in_time', ascending: false);

    final rows = <AttendanceRecordRow>[];

    for (final att in attendances) {
      final worker = att['workers'] as Map<String, dynamic>;
      final workerSiteId = worker['site_id'] as String?;
      final partId = worker['part_id'] as String?;
      final siteName = workerSiteId != null ? (_siteNames[workerSiteId] ?? '') : '';
      final partName = partId != null ? (_partNames[partId] ?? '') : '';

      // PostgREST returns 1:1 relations (UNIQUE FK) as object, not array
      final profiles = worker['worker_profiles'];
      final profile = profiles is Map<String, dynamic>
          ? profiles
          : (profiles is List && profiles.isNotEmpty) ? profiles.first : null;
      final position = (profile?['position'] as String?) ?? '';
      final job = (profile?['job'] as String?) ?? partName;

      final isNight = job.contains('야간') || partName.contains('야간');

      final checkInTime = DateTime.parse(att['check_in_time'] as String).toLocal();
      final checkInStr = '${checkInTime.hour.toString().padLeft(2, '0')}:${checkInTime.minute.toString().padLeft(2, '0')}';

      String checkOutStr = '-';
      String workHoursStr = '-';
      String status = '출근';
      String notes = att['notes'] as String? ?? '';

      if (att['check_out_time'] != null) {
        final checkOutTime = DateTime.parse(att['check_out_time'] as String).toLocal();
        checkOutStr = '${checkOutTime.hour.toString().padLeft(2, '0')}:${checkOutTime.minute.toString().padLeft(2, '0')}';

        final wh = att['work_hours'];
        if (wh != null) {
          final hours = (wh is num) ? wh.toDouble() : double.tryParse(wh.toString()) ?? 0;
          final h = hours.toInt();
          final m = ((hours - h) * 60).round();
          workHoursStr = '${h}h ${m}m';
        }

        if (!isNight && checkOutTime.hour < 16) {
          status = '조퇴';
        }
      }

      if (!isNight && checkInTime.hour >= 9 && checkInTime.minute > 0 && status == '출근') {
        status = '지각';
      }

      if (att['status'] == 'leave') {
        status = '조퇴';
      }

      rows.add(AttendanceRecordRow(
        id: att['id'] as String,
        workerId: att['worker_id'] as String,
        workerName: worker['name'] as String,
        position: position,
        job: job,
        site: siteName,
        date: checkInTime,
        checkInTime: checkInStr,
        checkOutTime: checkOutStr,
        workHours: workHoursStr,
        status: status,
        notes: notes,
      ));
    }

    return rows;
  }

  Future<void> updateAttendance(
    String id, {
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? status,
    String? notes,
  }) async {
    final updates = <String, dynamic>{};
    if (checkInTime != null) updates['check_in_time'] = checkInTime.toUtc().toIso8601String();
    if (checkOutTime != null) updates['check_out_time'] = checkOutTime.toUtc().toIso8601String();
    if (status != null) updates['status'] = status;
    if (notes != null) updates['notes'] = notes;

    if (updates.isEmpty) return;

    await _supabase.from('attendances').update(updates).eq('id', id);
  }

  Future<void> deleteAttendance(String id) async {
    // 소프트 삭제: status를 'deleted'로 변경 (데이터 보존)
    await _supabase.from('attendances').update({
      'status': 'deleted',
      'notes': '관리자에 의해 삭제됨 (${DateTime.now().toIso8601String().split('T').first})',
    }).eq('id', id);
  }
}

class AttendanceRecordRow {
  const AttendanceRecordRow({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.position,
    required this.job,
    required this.site,
    required this.date,
    required this.checkInTime,
    required this.checkOutTime,
    required this.workHours,
    required this.status,
    required this.notes,
  });

  final String id;
  final String workerId;
  final String workerName;
  final String position;
  final String job;
  final String site;
  final DateTime date;
  final String checkInTime;
  final String checkOutTime;
  final String workHours;
  final String status;
  final String notes;
}
