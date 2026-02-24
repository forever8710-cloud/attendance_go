import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/permissions.dart';
import '../../../core/widgets/modern_date_picker.dart';
import '../../../core/widgets/sticky_data_table.dart';
import '../data/attendance_records_repository.dart';
import '../providers/attendance_records_provider.dart';
import '../utils/attendance_excel_export.dart';
import 'widgets/attendance_edit_dialog.dart';
import 'widgets/attendance_delete_dialog.dart';

class AttendanceRecordsScreen extends ConsumerStatefulWidget {
  const AttendanceRecordsScreen({
    super.key,
    this.onWorkerTap,
    this.role = AppRole.worker,
  });

  final void Function(String id, String name)? onWorkerTap;
  final AppRole role;

  @override
  ConsumerState<AttendanceRecordsScreen> createState() => _AttendanceRecordsScreenState();
}

class _AttendanceRecordsScreenState extends ConsumerState<AttendanceRecordsScreen> {
  String _jobFilter = '전체';
  String _statusFilter = '전체';
  String _nameQuery = '';
  String _datePreset = '오늘';

  void _applyDatePreset(String preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTimeRange range;

    switch (preset) {
      case '오늘':
        range = DateTimeRange(start: today, end: today);
      case '이번주':
        final weekday = today.weekday; // 1=Mon, 7=Sun
        final monday = today.subtract(Duration(days: weekday - 1));
        range = DateTimeRange(start: monday, end: today);
      case '이번달':
        final monthStart = DateTime(now.year, now.month, 1);
        range = DateTimeRange(start: monthStart, end: today);
      case '전체기간':
        range = DateTimeRange(start: DateTime(2024, 1, 1), end: today);
      default:
        return;
    }

    setState(() => _datePreset = preset);
    ref.read(attendanceDateRangeProvider.notifier).state = range;
  }

  @override
  Widget build(BuildContext context) {
    final dateRange = ref.watch(attendanceDateRangeProvider);
    final attendances = ref.watch(attendanceRecordsProvider);
    final hasEditPermission = canEditAttendance(widget.role);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 상단 고정 영역 ──
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('근태 현황', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
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
                          '${DateFormat('MM/dd').format(dateRange.start)} ~ ${DateFormat('MM/dd').format(dateRange.end)}',
                        ),
                        onPressed: () async {
                          final range = await showModernDateRangePicker(
                            context: context,
                            initialRange: dateRange,
                            firstDate: DateTime(2024),
                            lastDate: DateTime.now(),
                          );
                          if (range != null) {
                            setState(() => _datePreset = '');
                            ref.read(attendanceDateRangeProvider.notifier).state = range;
                          }
                        },
                      ),
                      // 날짜 프리셋 칩
                      ...['오늘', '이번주', '이번달', '전체기간'].map((preset) {
                        final isSelected = _datePreset == preset;
                        return ChoiceChip(
                          label: Text(preset, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : null)),
                          selected: isSelected,
                          onSelected: (_) => _applyDatePreset(preset),
                          selectedColor: const Color(0xFF2B2D42),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: isSelected ? Colors.transparent : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                          visualDensity: VisualDensity.compact,
                        );
                      }),
                      _buildFilterDropdown('직무', _jobFilter, ['전체', '사무', '지게차', '피커', '검수', '지게차(야간)', '피커(야간)'],
                          (v) => setState(() => _jobFilter = v!)),
                      _buildFilterDropdown('상태', _statusFilter, ['전체', '출근', '지각', '조퇴', '미출근'],
                          (v) => setState(() => _statusFilter = v!)),
                      SizedBox(
                        width: 200,
                        height: 36,
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
                        onPressed: () {
                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
                          ref.read(attendanceDateRangeProvider.notifier).state =
                              DateTimeRange(start: today, end: today);
                          setState(() {
                            _jobFilter = '전체';
                            _statusFilter = '전체';
                            _nameQuery = '';
                            _datePreset = '오늘';
                          });
                        },
                        child: const Text('초기화'),
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
                  if (_nameQuery.isNotEmpty && !r.workerName.contains(_nameQuery)) return false;
                  return true;
                }).toList();

                final columns = [
                  const TableColumnDef(label: 'No.', width: 45),
                  const TableColumnDef(label: '날짜', width: 95),
                  const TableColumnDef(label: '성명', width: 75),
                  const TableColumnDef(label: '직위', width: 65),
                  const TableColumnDef(label: '직무', width: 95),
                  const TableColumnDef(label: '사업장', width: 75),
                  const TableColumnDef(label: '출근', width: 65),
                  const TableColumnDef(label: '퇴근', width: 65),
                  const TableColumnDef(label: '근무시간', width: 80),
                  const TableColumnDef(label: '상태', width: 75),
                  if (hasEditPermission) const TableColumnDef(label: '관리', width: 80),
                ];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('총 ${filtered.length}건', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55))),
                        const Spacer(),
                        if (filtered.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: () {
                              final label = '${DateFormat('yyyyMMdd').format(dateRange.start)}_${DateFormat('yyyyMMdd').format(dateRange.end)}';
                              AttendanceExcelExport.exportToExcel(filtered, label);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('엑셀 파일이 다운로드되었습니다.')),
                              );
                            },
                            icon: const Icon(Icons.download, size: 16),
                            label: const Text('엑셀 내보내기'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: StickyHeaderTable.wrapWithCard(
                        columns: columns,
                        rowCount: filtered.length,
                        cellBuilder: (colIndex, rowIndex) {
                          final r = filtered[rowIndex];
                          final maxCol = hasEditPermission ? 10 : 9;
                          return switch (colIndex) {
                            0 => Text('${rowIndex + 1}', style: const TextStyle(fontSize: 13)),
                            1 => Text(DateFormat('yyyy-MM-dd').format(r.date), style: const TextStyle(fontSize: 13)),
                            2 => Tooltip(
                                message: r.workerName,
                                child: widget.onWorkerTap != null
                                    ? GestureDetector(
                                        onTap: () => widget.onWorkerTap!(r.workerId, r.workerName),
                                        child: Text(r.workerName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.deepPurple, decoration: TextDecoration.underline, decorationColor: Colors.deepPurple)),
                                      )
                                    : Text(r.workerName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                            3 => Text(r.position, style: const TextStyle(fontSize: 13)),
                            4 => Text(r.job, style: const TextStyle(fontSize: 13)),
                            5 => Text(r.site, style: const TextStyle(fontSize: 13)),
                            6 => Text(r.checkInTime, style: const TextStyle(fontSize: 13)),
                            7 => Text(r.checkOutTime, style: const TextStyle(fontSize: 13)),
                            8 => Text(r.workHours, style: const TextStyle(fontSize: 13)),
                            9 => _buildStatusBadge(r.status),
                            _ when colIndex == maxCol && hasEditPermission =>
                              _buildActionButtons(r),
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

  Widget _buildActionButtons(AttendanceRecordRow record) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _showEditDialog(record),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.edit_outlined, size: 18, color: const Color(0xFF8D99AE)),
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () => _showDeleteDialog(record),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.delete_outline, size: 18, color: Colors.red[600]),
          ),
        ),
      ],
    );
  }

  Future<void> _showEditDialog(AttendanceRecordRow record) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AttendanceEditDialog(record: record),
    );

    if (result != null && mounted) {
      try {
        await ref.read(attendanceRecordsRepositoryProvider).updateAttendance(
              record.id,
              checkInTime: result['checkInTime'] as DateTime?,
              checkOutTime: result['checkOutTime'] as DateTime?,
              status: result['status'] as String?,
              notes: result['notes'] as String?,
            );
        ref.invalidate(attendanceRecordsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('근태 기록이 수정되었습니다.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('수정 실패: $e')),
          );
        }
      }
    }
  }

  Future<void> _showDeleteDialog(AttendanceRecordRow record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AttendanceDeleteDialog(record: record),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(attendanceRecordsRepositoryProvider).deleteAttendance(record.id);
        ref.invalidate(attendanceRecordsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('근태 기록이 삭제되었습니다.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: $e')),
          );
        }
      }
    }
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
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
      '퇴근' => const Color(0xFF8D99AE),
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
