import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/company_constants.dart';
import '../../../core/widgets/sticky_data_table.dart';
import '../../workers/providers/workers_provider.dart';
import '../providers/worker_detail_provider.dart';

class WorkerDetailScreen extends ConsumerWidget {
  const WorkerDetailScreen({
    super.key,
    required this.workerId,
    required this.workerName,
    required this.onBack,
  });

  final String workerId;
  final String workerName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workersAsync = ref.watch(workersProvider);
    final yearMonth = ref.watch(detailYearMonthProvider);
    final attendanceAsync = ref.watch(workerMonthlyAttendanceProvider(workerId));
    final summaryAsync = ref.watch(workerMonthlySummaryProvider(workerId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 상단: 뒤로가기 + 타이틀 ──
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, size: 22),
                tooltip: '뒤로가기',
              ),
              const SizedBox(width: 8),
              Text(
                '근로자 상세 - $workerName',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // ── 스크롤 영역: 인사기록카드 + 근태 테이블 ──
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 인사기록카드 ──
                workersAsync.when(
                  data: (workers) {
                    final worker = workers.where((w) => w.id == workerId).firstOrNull;
                    if (worker == null) {
                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                '상세 인사정보가 등록되지 않았습니다',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45), fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.badge, color: Colors.indigo, size: 20),
                                const SizedBox(width: 8),
                                const Text('인사기록카드', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text('읽기전용', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45))),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 사진
                                Container(
                                  width: 100,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                                  ),
                                  child: worker.photoUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(worker.photoUrl!, fit: BoxFit.cover),
                                        )
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.person, size: 40, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
                                            const SizedBox(height: 4),
                                            Text('반명함', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11)),
                                          ],
                                        ),
                                ),
                                const SizedBox(width: 24),

                                // 정보
                                Expanded(
                                  child: Column(
                                    children: [
                                      // 1행: 성명, 사번, 소속회사, 전화번호
                                      Row(
                                        children: [
                                          Expanded(child: _buildInfoField('성명', worker.name)),
                                          const SizedBox(width: 12),
                                          Expanded(child: _buildInfoField('사번', worker.employeeId ?? '-')),
                                          const SizedBox(width: 12),
                                          Expanded(child: _buildInfoField('소속회사', worker.company != null ? CompanyConstants.companyName(worker.company!) : '-')),
                                          const SizedBox(width: 12),
                                          Expanded(child: _buildInfoField('전화번호', worker.phone)),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      // 2행: 직위, 직무, 사업장, 재직상태, 입사일
                                      Row(
                                        children: [
                                          Expanded(child: _buildInfoField('직위', worker.position ?? '-')),
                                          const SizedBox(width: 12),
                                          Expanded(child: _buildInfoField('직무', worker.job ?? worker.part)),
                                          const SizedBox(width: 12),
                                          Expanded(child: _buildInfoField('사업장', worker.site)),
                                          const SizedBox(width: 12),
                                          Expanded(child: _buildInfoField('재직상태', worker.employmentStatus ?? (worker.isActive ? '재직' : '퇴사'))),
                                          const SizedBox(width: 12),
                                          Expanded(child: _buildInfoField('입사일', worker.joinDate != null ? DateFormat('yyyy-MM-dd').format(worker.joinDate!) : '-')),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('오류: $e'),
                ),

                const SizedBox(height: 20),

                // ── 월별 근태 현황 헤더 + 월 선택 ──
                Row(
                  children: [
                    const Text(
                      '▶ 월별 근태 현황',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const SizedBox(width: 16),
                    _buildMonthSelector(context, ref, yearMonth),
                  ],
                ),
                const SizedBox(height: 12),

                // ── 요약 카드 5개 ──
                summaryAsync.when(
                  data: (summary) => Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildSummaryCard('출근일수', '${summary.workDays}일', Icons.login, Colors.green),
                      _buildSummaryCard('지각', '${summary.lateDays}일', Icons.warning, Colors.orange),
                      _buildSummaryCard('조퇴', '${summary.earlyLeaveDays}일', Icons.exit_to_app, Colors.purple),
                      _buildSummaryCard('결근', '${summary.absentDays}일', Icons.person_off, Colors.red),
                      _buildSummaryCard('잔여연차', '${summary.remainingLeave}일', Icons.beach_access, Colors.teal),
                    ],
                  ),
                  loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
                  error: (e, _) => Text('오류: $e'),
                ),
                const SizedBox(height: 16),

                // ── 근태 테이블 ──
                Expanded(
                  child: attendanceAsync.when(
                    data: (rows) {
                      final columns = [
                        const TableColumnDef(label: '날짜', width: 125),
                        const TableColumnDef(label: '출근', width: 80),
                        const TableColumnDef(label: '퇴근', width: 80),
                        const TableColumnDef(label: '근무시간', width: 90),
                        const TableColumnDef(label: '상태', width: 80),
                        const TableColumnDef(label: '적요', width: 180),
                      ];

                      return StickyHeaderTable.wrapWithCard(
                        columns: columns,
                        rowCount: rows.length,
                        rowColorBuilder: (i) {
                          if (rows[i].status == '휴일') {
                            return Colors.grey.withValues(alpha: 0.08);
                          }
                          return null;
                        },
                        cellBuilder: (colIndex, rowIndex) {
                          final r = rows[rowIndex];
                          return switch (colIndex) {
                            0 => Text(
                              DateFormat('yyyy-MM-dd (E)', 'ko').format(r.date),
                              style: TextStyle(
                                fontSize: 13,
                                color: r.status == '휴일' ? Colors.grey : null,
                              ),
                            ),
                            1 => Text(r.checkIn, style: const TextStyle(fontSize: 13)),
                            2 => Text(r.checkOut, style: const TextStyle(fontSize: 13)),
                            3 => Text(r.workHours, style: const TextStyle(fontSize: 13)),
                            4 => _buildStatusBadge(r.status),
                            5 => r.note.isNotEmpty
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(r.note, style: const TextStyle(fontSize: 12)),
                                  )
                                : const SizedBox(),
                            _ => const SizedBox(),
                          };
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('오류: $e')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.55))),
          const SizedBox(height: 2),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      );
    });
  }

  Widget _buildMonthSelector(BuildContext context, WidgetRef ref, String yearMonth) {
    final cs = Theme.of(context).colorScheme;
    final items = <DropdownMenuItem<String>>[];
    final now = DateTime.now();
    for (int i = 0; i < 12; i++) {
      final d = DateTime(now.year, now.month - i);
      final val = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      items.add(DropdownMenuItem(value: val, child: Text(val)));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: yearMonth,
          items: items,
          onChanged: (v) => ref.read(detailYearMonthProvider.notifier).state = v!,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return Container(
        width: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(title, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.55), fontSize: 11)),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      );
    });
  }

  Widget _buildStatusBadge(String status) {
    final color = switch (status) {
      '지각' => Colors.orange,
      '출근' => Colors.green,
      '퇴근' => Colors.indigo,
      '조퇴' => Colors.purple,
      '미출근' => Colors.red,
      '휴일' => Colors.grey,
      '연차' => Colors.teal,
      _ => Colors.grey,
    };
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
