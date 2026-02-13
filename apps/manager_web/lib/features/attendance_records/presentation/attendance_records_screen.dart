import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/sticky_data_table.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class AttendanceRecordsScreen extends ConsumerStatefulWidget {
  const AttendanceRecordsScreen({super.key, this.onWorkerTap});

  final void Function(String id, String name)? onWorkerTap;

  @override
  ConsumerState<AttendanceRecordsScreen> createState() => _AttendanceRecordsScreenState();
}

class _AttendanceRecordsScreenState extends ConsumerState<AttendanceRecordsScreen> {
  DateTimeRange? _dateRange;
  String _jobFilter = '전체';
  String _statusFilter = '전체';
  String _nameQuery = '';

  @override
  Widget build(BuildContext context) {
    final attendances = ref.watch(todayAttendancesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 상단 고정 영역 ──
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('근태 기록', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // Filters
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
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
                      _buildFilterDropdown('직무', _jobFilter, ['전체', '사무', '지게차', '피커', '검수', '지게차(야간)', '피커(야간)'],
                          (v) => setState(() => _jobFilter = v!)),
                      _buildFilterDropdown('상태', _statusFilter, ['전체', '출근', '퇴근', '지각', '조퇴', '미출근'],
                          (v) => setState(() => _statusFilter = v!)),
                      SizedBox(
                        width: 180,
                        height: 38,
                        child: TextField(
                          onChanged: (v) => setState(() => _nameQuery = v),
                          decoration: InputDecoration(
                            hintText: '이름 검색...',
                            prefixIcon: const Icon(Icons.search, size: 18),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _dateRange = null;
                          _jobFilter = '전체';
                          _statusFilter = '전체';
                          _nameQuery = '';
                        }),
                        child: const Text('초기화'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('엑셀 파일이 다운로드되었습니다. (TODO: 실제 엑셀 생성)')),
                          );
                        },
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('엑셀 내보내기'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // ── 하단: 테이블 (헤더 고정) ──
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
            child: attendances.when(
              data: (rows) {
                var filtered = rows.where((r) {
                  if (_jobFilter != '전체' && r.job != _jobFilter) return false;
                  if (_statusFilter != '전체' && r.status != _statusFilter) return false;
                  if (_nameQuery.isNotEmpty && !r.name.contains(_nameQuery)) return false;
                  return true;
                }).toList();

                final columns = [
                  const TableColumnDef(label: 'No.', width: 55),
                  const TableColumnDef(label: '날짜', width: 105),
                  const TableColumnDef(label: '성명', width: 85),
                  const TableColumnDef(label: '직위', width: 75),
                  const TableColumnDef(label: '직무', width: 110),
                  const TableColumnDef(label: '사업장', width: 85),
                  const TableColumnDef(label: '출근', width: 75),
                  const TableColumnDef(label: '퇴근', width: 75),
                  const TableColumnDef(label: '근무시간', width: 90),
                  const TableColumnDef(label: '상태', width: 80),
                ];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('총 ${filtered.length}건', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55))),
                    const SizedBox(height: 12),
                    Expanded(
                      child: StickyHeaderTable.wrapWithCard(
                        columns: columns,
                        rowCount: filtered.length,
                        cellBuilder: (colIndex, rowIndex) {
                          final r = filtered[rowIndex];
                          return switch (colIndex) {
                            0 => Text('${rowIndex + 1}', style: const TextStyle(fontSize: 13)),
                            1 => Text(DateFormat('yyyy-MM-dd').format(DateTime.now()), style: const TextStyle(fontSize: 13)),
                            2 => widget.onWorkerTap != null
                                ? GestureDetector(
                                    onTap: () => widget.onWorkerTap!(r.id ?? '', r.name),
                                    child: Text(r.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.indigo, decoration: TextDecoration.underline)),
                                  )
                                : Text(r.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            3 => Text(r.position, style: const TextStyle(fontSize: 13)),
                            4 => Text(r.job, style: const TextStyle(fontSize: 13)),
                            5 => Text(r.site, style: const TextStyle(fontSize: 13)),
                            6 => Text(r.checkIn, style: const TextStyle(fontSize: 13)),
                            7 => Text(r.checkOut, style: const TextStyle(fontSize: 13)),
                            8 => Text(r.workHours, style: const TextStyle(fontSize: 13)),
                            9 => _buildStatusBadge(r.status),
                            _ => const SizedBox(),
                          };
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('오류: $e'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
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
      '지각' => Colors.orange,
      '출근' => Colors.green,
      '퇴근' => Colors.indigo,
      '조퇴' => Colors.purple,
      '미출근' => Colors.red,
      _ => Colors.grey,
    };
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(15)),
        child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
