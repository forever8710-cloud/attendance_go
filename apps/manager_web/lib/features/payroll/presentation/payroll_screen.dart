import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/permissions.dart';
import '../../../core/widgets/sticky_data_table.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/payroll_repository.dart';
import '../providers/payroll_provider.dart';
import '../utils/payroll_excel_export.dart';

class PayrollScreen extends ConsumerStatefulWidget {
  const PayrollScreen({super.key, required this.role, this.onWorkerTap});

  final AppRole role;
  final void Function(String id, String name)? onWorkerTap;

  @override
  ConsumerState<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends ConsumerState<PayrollScreen> {
  List<PayrollRow>? _payrollData;
  Set<String> _finalizedWorkerIds = {};
  bool _loading = false;
  bool _finalizing = false;
  final _numberFormat = NumberFormat('#,###');

  bool get _allFinalized =>
      _payrollData != null &&
      _payrollData!.isNotEmpty &&
      _payrollData!.every((r) => _finalizedWorkerIds.contains(r.workerId));

  @override
  Widget build(BuildContext context) {
    final yearMonth = ref.watch(selectedYearMonthProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child:
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Year-month selector + generate button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: yearMonth,
                        items: _buildMonthItems(),
                        onChanged: (v) => ref.read(selectedYearMonthProvider.notifier).state = v!,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: _loading ? null : () => _generatePayroll(yearMonth),
                    icon: _loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.calculate, size: 18),
                    label: const Text('급여대장 생성'),
                  ),
                  if (_payrollData != null && canEditPayroll(widget.role)) ...[
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _payrollData!.isEmpty
                          ? null
                          : () {
                              PayrollExcelExport.exportToExcel(_payrollData!, yearMonth);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('엑셀 파일이 다운로드되었습니다.')),
                              );
                            },
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('엑셀 내보내기'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: _allFinalized ? '모두 확정됨' : '급여대장을 확정합니다',
                      child: FilledButton(
                        onPressed: (_allFinalized || _finalizing || _payrollData!.isEmpty)
                            ? null
                            : () => _showFinalizeDialog(yearMonth),
                        style: FilledButton.styleFrom(backgroundColor: Colors.orange[700]),
                        child: _finalizing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(_allFinalized ? '확정 완료' : '확정'),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              if (_payrollData != null)
                Text('▶ 급여대장 (${ref.read(selectedYearMonthProvider)})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8D99AE))),
              if (_payrollData != null) const SizedBox(height: 12),
            ],
          ),
        ),
        ),
        SliverLayoutBuilder(
          builder: (context, constraints) {
            final remaining = constraints.viewportMainAxisExtent - constraints.precedingScrollExtent;
            final tableHeight = remaining < 500 ? 500.0 : remaining;
            return SliverToBoxAdapter(child:
        SizedBox(
          height: tableHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
            child: _payrollData == null && !_loading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payments_outlined, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Text('년월을 선택하고 "급여대장 생성" 버튼을 클릭하세요', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 16)),
                      ],
                    ),
                  )
                : _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildPayrollTable(),
          ),
        ),
            );
          },
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _buildMonthItems() {
    final items = <DropdownMenuItem<String>>[];
    final now = DateTime.now();
    for (int i = 0; i < 12; i++) {
      final d = DateTime(now.year, now.month - i);
      final val = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      items.add(DropdownMenuItem(value: val, child: Text(val)));
    }
    return items;
  }

  Future<void> _generatePayroll(String yearMonth) async {
    setState(() => _loading = true);
    try {
      final auth = ref.read(authProvider);
      final siteId = canAccessAllSites(auth.role) ? '' : (auth.worker?.siteId ?? '');
      final repo = ref.read(payrollRepositoryProvider);
      final results = await Future.wait([
        repo.calculatePayroll(siteId, yearMonth),
        repo.checkFinalizationStatus(yearMonth),
      ]);
      setState(() {
        _payrollData = results[0] as List<PayrollRow>;
        _finalizedWorkerIds = results[1] as Set<String>;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
      }
    }
  }

  Future<void> _showFinalizeDialog(String yearMonth) async {
    final unfinalizedCount = _payrollData!.where((r) => !_finalizedWorkerIds.contains(r.workerId)).length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('급여 확정'),
        content: Text('$yearMonth 급여대장을 확정하시겠습니까?\n\n미확정 $unfinalizedCount명의 급여가 확정됩니다.\n확정 후에는 수정이 어렵습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange[700]),
            child: const Text('확정'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _finalizing = true);
    try {
      final count = await ref.read(payrollRepositoryProvider).finalizePayroll(_payrollData!, yearMonth);
      setState(() {
        _finalizedWorkerIds = _payrollData!.map((r) => r.workerId).toSet();
        _finalizing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$count명의 급여가 확정되었습니다.')),
        );
      }
    } catch (e) {
      setState(() => _finalizing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('확정 오류: $e')));
      }
    }
  }

  Widget _buildPayrollTable() {
    final data = _payrollData!;
    final totalSalary = data.fold<int>(0, (sum, r) => sum + r.totalSalary);
    final totalHours = data.fold<double>(0, (sum, r) => sum + r.totalHours);
    final totalDays = data.fold<int>(0, (sum, r) => sum + r.workDays);

    // rowCount = data rows + 1 (합계 행)
    final rowCount = data.length + 1;

    final columns = [
      const TableColumnDef(label: 'No.', width: 45),
      const TableColumnDef(label: '성명', width: 75),
      const TableColumnDef(label: '파트', width: 95),
      const TableColumnDef(label: '출근일수', width: 75, numeric: true),
      const TableColumnDef(label: '총 근무시간', width: 90, numeric: true),
      const TableColumnDef(label: '시급', width: 80, numeric: true),
      const TableColumnDef(label: '기본급', width: 95, numeric: true),
      const TableColumnDef(label: '총 급여', width: 110, numeric: true),
      const TableColumnDef(label: '상태', width: 75),
    ];

    return StickyHeaderTable.wrapWithCard(
      columns: columns,
      rowCount: rowCount,
      rowColorBuilder: (i) {
        if (i == data.length) {
          return Colors.amber.withValues(alpha: 0.08);
        }
        return null;
      },
      cellBuilder: (colIndex, rowIndex) {
        if (rowIndex == data.length) {
          return switch (colIndex) {
            0 => const SizedBox(),
            1 => const Text('합계', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            2 => const SizedBox(),
            3 => Text('$totalDays', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            4 => Text(totalHours.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            5 => const SizedBox(),
            6 => const SizedBox(),
            7 => Text('${_numberFormat.format(totalSalary)}원', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            8 => const SizedBox(),
            _ => const SizedBox(),
          };
        }

        final r = data[rowIndex];
        final isFinalized = _finalizedWorkerIds.contains(r.workerId);

        return switch (colIndex) {
          0 => Text('${rowIndex + 1}', style: const TextStyle(fontSize: 13)),
          1 => Tooltip(
              message: r.name,
              child: widget.onWorkerTap != null
                  ? GestureDetector(
                      onTap: () => widget.onWorkerTap!(r.workerId, r.name),
                      child: Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.deepPurple, decoration: TextDecoration.underline, decorationColor: Colors.deepPurple)),
                    )
                  : Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          2 => Text(r.part, style: const TextStyle(fontSize: 13)),
          3 => Text('${r.workDays}', style: const TextStyle(fontSize: 13)),
          4 => Text(r.totalHours.toStringAsFixed(1), style: const TextStyle(fontSize: 13)),
          5 => Text('${_numberFormat.format(r.hourlyWage)}원', style: const TextStyle(fontSize: 13)),
          6 => Text('${_numberFormat.format(r.baseSalary)}원', style: const TextStyle(fontSize: 13)),
          7 => Text('${_numberFormat.format(r.totalSalary)}원', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          8 => isFinalized
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text('확정', style: TextStyle(fontSize: 11, color: Colors.green[700], fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              : Text('미확정', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          _ => const SizedBox(),
        };
      },
    );
  }
}
