import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/permissions.dart';
import '../data/payroll_repository.dart';
import '../providers/payroll_provider.dart';

class PayrollScreen extends ConsumerStatefulWidget {
  const PayrollScreen({super.key, required this.role});

  final AppRole role;

  @override
  ConsumerState<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends ConsumerState<PayrollScreen> {
  List<PayrollRow>? _payrollData;
  bool _loading = false;
  final _numberFormat = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final yearMonth = ref.watch(selectedYearMonthProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('급여 관리', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // Year-month selector + generate button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
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
              const Spacer(),
              if (_payrollData != null && canEditPayroll(widget.role)) ...[
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
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('급여대장이 확정되었습니다.')),
                    );
                  },
                  style: FilledButton.styleFrom(backgroundColor: Colors.orange[700]),
                  child: const Text('확정'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          if (_payrollData == null && !_loading)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Column(
                  children: [
                    Icon(Icons.payments_outlined, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('년월을 선택하고 "급여대장 생성" 버튼을 클릭하세요', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                  ],
                ),
              ),
            ),

          if (_payrollData != null) _buildPayrollTable(),
        ],
      ),
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
      final data = await ref.read(payrollRepositoryProvider).calculatePayroll('demo-site-id', yearMonth);
      setState(() {
        _payrollData = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
      }
    }
  }

  Widget _buildPayrollTable() {
    final data = _payrollData!;
    final totalSalary = data.fold<int>(0, (sum, r) => sum + r.totalSalary);
    final totalHours = data.fold<double>(0, (sum, r) => sum + r.totalHours);
    final totalDays = data.fold<int>(0, (sum, r) => sum + r.workDays);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('▶ 급여대장 (${ref.read(selectedYearMonthProvider)})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
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
                  DataColumn(label: Text('성명')),
                  DataColumn(label: Text('파트')),
                  DataColumn(label: Text('출근일수'), numeric: true),
                  DataColumn(label: Text('총 근무시간'), numeric: true),
                  DataColumn(label: Text('시급'), numeric: true),
                  DataColumn(label: Text('기본급'), numeric: true),
                  DataColumn(label: Text('총 급여'), numeric: true),
                ],
                rows: [
                  ...data.asMap().entries.map((entry) {
                    final i = entry.key;
                    final r = entry.value;
                    return DataRow(cells: [
                      DataCell(Text('${i + 1}')),
                      DataCell(Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(r.part)),
                      DataCell(Text('${r.workDays}')),
                      DataCell(Text(r.totalHours.toStringAsFixed(1))),
                      DataCell(Text('${_numberFormat.format(r.hourlyWage)}원')),
                      DataCell(Text('${_numberFormat.format(r.baseSalary)}원')),
                      DataCell(Text('${_numberFormat.format(r.totalSalary)}원', style: const TextStyle(fontWeight: FontWeight.bold))),
                    ]);
                  }),
                  // Total row
                  DataRow(
                    color: WidgetStateProperty.all(Colors.amber.withValues(alpha: 0.08)),
                    cells: [
                      const DataCell(Text('')),
                      const DataCell(Text('합계', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                      const DataCell(Text('')),
                      DataCell(Text('$totalDays', style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(totalHours.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold))),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      DataCell(Text('${_numberFormat.format(totalSalary)}원', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
