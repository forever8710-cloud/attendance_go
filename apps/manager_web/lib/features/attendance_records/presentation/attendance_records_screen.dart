import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class AttendanceRecordsScreen extends ConsumerStatefulWidget {
  const AttendanceRecordsScreen({super.key});

  @override
  ConsumerState<AttendanceRecordsScreen> createState() => _AttendanceRecordsScreenState();
}

class _AttendanceRecordsScreenState extends ConsumerState<AttendanceRecordsScreen> {
  DateTimeRange? _dateRange;
  String _partFilter = '전체';
  String _statusFilter = '전체';

  @override
  Widget build(BuildContext context) {
    final attendances = ref.watch(todayAttendancesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('근태 기록', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // Filters
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Date range
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _dateRange != null
                          ? '${DateFormat('MM/dd').format(_dateRange!.start)} ~ ${DateFormat('MM/dd').format(_dateRange!.end)}'
                          : '날짜 선택',
                    ),
                    onPressed: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2024),
                        lastDate: DateTime.now(),
                      );
                      if (range != null) setState(() => _dateRange = range);
                    },
                  ),
                  // Part filter
                  _buildFilterDropdown('파트', _partFilter, ['전체', '현장', '사무', '지게차', '일용직'],
                      (v) => setState(() => _partFilter = v!)),
                  // Status filter
                  _buildFilterDropdown('상태', _statusFilter, ['전체', '출근', '지각', '미출근'],
                      (v) => setState(() => _statusFilter = v!)),
                  // Reset
                  TextButton(
                    onPressed: () => setState(() {
                      _dateRange = null;
                      _partFilter = '전체';
                      _statusFilter = '전체';
                    }),
                    child: const Text('초기화'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Table
          attendances.when(
            data: (rows) {
              var filtered = rows.where((r) {
                if (_partFilter != '전체' && r.part != _partFilter) return false;
                if (_statusFilter != '전체' && r.status != _statusFilter) return false;
                return true;
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('총 ${filtered.length}건', style: TextStyle(color: Colors.grey[600])),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('엑셀 내보내기'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 28,
                          columns: const [
                            DataColumn(label: Text('No.')),
                            DataColumn(label: Text('날짜')),
                            DataColumn(label: Text('성명')),
                            DataColumn(label: Text('파트')),
                            DataColumn(label: Text('사업장')),
                            DataColumn(label: Text('출근')),
                            DataColumn(label: Text('퇴근')),
                            DataColumn(label: Text('근무시간')),
                            DataColumn(label: Text('상태')),
                          ],
                          rows: filtered.asMap().entries.map((entry) {
                            final i = entry.key;
                            final r = entry.value;
                            return DataRow(cells: [
                              DataCell(Text('${i + 1}')),
                              DataCell(Text(DateFormat('yyyy-MM-dd').format(DateTime.now()))),
                              DataCell(Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(r.part)),
                              DataCell(Text(r.site)),
                              DataCell(Text(r.checkIn)),
                              DataCell(Text(r.checkOut)),
                              DataCell(Text(r.workHours)),
                              DataCell(_buildStatusBadge(r.status)),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('오류: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((v) => DropdownMenuItem(value: v, child: Text('$label: $v', style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = switch (status) {
      '지각' => Colors.red,
      '출근' => Colors.green,
      '미출근' => Colors.grey,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
