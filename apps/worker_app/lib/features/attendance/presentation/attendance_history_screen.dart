import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/attendance_provider.dart';

final _monthProvider = StateProvider<DateTime>((ref) => DateTime.now());

final _monthlyAttendancesProvider = FutureProvider.family<List<Attendance>, DateTime>((ref, month) async {
  final worker = ref.watch(authProvider).worker;
  if (worker == null) return [];
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.getMonthlyAttendances(worker.id, month.year, month.month);
});

class AttendanceHistoryScreen extends ConsumerWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(_monthProvider);
    final attendances = ref.watch(_monthlyAttendancesProvider(month));
    final monthFormat = DateFormat('yyyy년 MM월');
    final dateFormat = DateFormat('MM/dd (E)', 'ko');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('근태 기록')),
      body: Column(
        children: [
          // Month selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => ref.read(_monthProvider.notifier).state =
                      DateTime(month.year, month.month - 1),
                ),
                Text(monthFormat.format(month),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: month.month >= DateTime.now().month && month.year >= DateTime.now().year
                      ? null
                      : () => ref.read(_monthProvider.notifier).state =
                            DateTime(month.year, month.month + 1),
                ),
              ],
            ),
          ),

          // Attendance list
          Expanded(
            child: attendances.when(
              data: (records) {
                if (records.isEmpty) {
                  return const Center(child: Text('기록이 없습니다'));
                }
                // Summary
                final totalDays = records.length;
                final totalHours = records.fold<double>(0, (sum, r) => sum + (r.workHours ?? 0));

                return Column(
                  children: [
                    // Summary cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _summaryCard('출근일수', '$totalDays일', Colors.green),
                          const SizedBox(width: 12),
                          _summaryCard('총 근무시간', '${totalHours.toStringAsFixed(1)}h', Colors.indigo),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: records.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final r = records[records.length - 1 - index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.withValues(alpha: 0.1),
                              child: const Icon(Icons.check, color: Colors.green, size: 20),
                            ),
                            title: Text(dateFormat.format(r.checkInTime)),
                            subtitle: Text(
                              '${timeFormat.format(r.checkInTime)} ~ ${r.checkOutTime != null ? timeFormat.format(r.checkOutTime!) : '-'}',
                            ),
                            trailing: Text(
                              r.workHours != null ? '${r.workHours!.toStringAsFixed(1)}h' : '-',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontSize: 13)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
