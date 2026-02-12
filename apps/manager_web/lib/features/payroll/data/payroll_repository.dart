import 'package:supabase_client/supabase_client.dart';

class PayrollRow {
  const PayrollRow({
    required this.workerId,
    required this.name,
    required this.part,
    required this.workDays,
    required this.totalHours,
    required this.hourlyWage,
    required this.baseSalary,
    required this.totalSalary,
  });
  final String workerId;
  final String name, part;
  final int workDays;
  final double totalHours;
  final int hourlyWage, baseSalary, totalSalary;
}

class PayrollRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Map<String, String> _partNames = {};
  Map<String, int> _partWages = {};

  Future<void> _loadParts() async {
    if (_partNames.isNotEmpty) return;
    final parts = await _supabase.from('parts').select('id, name, hourly_wage');
    _partNames = {for (final p in parts) p['id'] as String: p['name'] as String};
    _partWages = {for (final p in parts) p['id'] as String: (p['hourly_wage'] as num).toInt()};
  }

  Future<List<PayrollRow>> calculatePayroll(String siteId, String yearMonth) async {
    await _loadParts();

    final parts = yearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    final start = DateTime(year, month, 1).toUtc().toIso8601String();
    final end = DateTime(year, month + 1, 1).toUtc().toIso8601String();

    // 활성 근로자 목록
    final workers = await _supabase
        .from('workers')
        .select('id, name, part_id')
        .eq('is_active', true)
        .eq('role', 'worker');

    // 해당 월 출퇴근 기록
    final attendances = await _supabase
        .from('attendances')
        .select('worker_id, work_hours')
        .gte('check_in_time', start)
        .lt('check_in_time', end);

    // worker_id별 집계
    final workerStats = <String, ({int days, double hours})>{};
    for (final att in attendances) {
      final wId = att['worker_id'] as String;
      final wh = att['work_hours'];
      final hours = wh != null
          ? ((wh is num) ? wh.toDouble() : double.tryParse(wh.toString()) ?? 0)
          : 0.0;
      final prev = workerStats[wId] ?? (days: 0, hours: 0.0);
      workerStats[wId] = (days: prev.days + 1, hours: prev.hours + hours);
    }

    final rows = <PayrollRow>[];
    for (final w in workers) {
      final wId = w['id'] as String;
      final partId = w['part_id'] as String?;
      final partName = partId != null ? (_partNames[partId] ?? '-') : '-';
      final hourlyWage = partId != null ? (_partWages[partId] ?? 0) : 0;

      final stats = workerStats[wId];
      if (stats == null || stats.days == 0) continue;

      final baseSalary = (stats.hours * hourlyWage).round();
      rows.add(PayrollRow(
        workerId: wId,
        name: w['name'] as String,
        part: partName,
        workDays: stats.days,
        totalHours: stats.hours,
        hourlyWage: hourlyWage,
        baseSalary: baseSalary,
        totalSalary: baseSalary,
      ));
    }

    rows.sort((a, b) => a.name.compareTo(b.name));
    return rows;
  }
}
