import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/dashboard_repository.dart';

/// 7일간 출근율 추이 라인차트
class AttendanceTrendChart extends StatelessWidget {
  const AttendanceTrendChart({super.key, required this.stats});

  final List<DailyAttendanceStat> stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (stats.isEmpty) {
      return const Center(child: Text('데이터가 없습니다.'));
    }

    final spots = stats.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.attendanceRate);
    }).toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '주간 출근율 추이',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 25,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: cs.outlineVariant.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 25,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}%',
                          style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5)),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= stats.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('M/d').format(stats[idx].date),
                              style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5)),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: const Color(0xFF8D99AE),
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF8D99AE),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF8D99AE).withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final idx = spot.x.toInt();
                          final stat = stats[idx];
                          return LineTooltipItem(
                            '${DateFormat('M/d').format(stat.date)}\n${stat.attendanceRate.toStringAsFixed(1)}% (${stat.presentCount}/${stat.totalWorkers}명)',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 오늘 출근 상태 분포 파이차트
class StatusDistributionChart extends StatelessWidget {
  const StatusDistributionChart({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = summary.totalWorkers;

    if (total == 0) {
      return const Center(child: Text('데이터가 없습니다.'));
    }

    final present = summary.dayCheckedIn + summary.nightCheckedIn - summary.checkedOut - summary.late - (summary.earlyLeave ?? 0);
    final sections = <_PieSection>[
      _PieSection('정상출근', present < 0 ? 0 : present, Colors.green),
      _PieSection('지각', summary.late, Colors.orange),
      _PieSection('조퇴', summary.earlyLeave ?? 0, Colors.purple),
      _PieSection('미출근', summary.absent, Colors.red),
    ].where((s) => s.value > 0).toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘 출근 현황',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        sections: sections.map((s) {
                          return PieChartSectionData(
                            color: s.color,
                            value: s.value.toDouble(),
                            title: '${s.value}',
                            radius: 45,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sections.map((s) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: s.color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${s.label} ${s.value}명',
                              style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.7)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PieSection {
  const _PieSection(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;
}
