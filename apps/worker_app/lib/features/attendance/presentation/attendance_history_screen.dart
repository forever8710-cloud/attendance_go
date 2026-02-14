import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/status_card.dart';
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
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                '근태기록',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // 월 선택
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: () => ref.read(_monthProvider.notifier).state =
                          DateTime(month.year, month.month - 1),
                    ),
                    Text(
                      monthFormat.format(month),
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: month.month >= DateTime.now().month &&
                              month.year >= DateTime.now().year
                          ? null
                          : () => ref.read(_monthProvider.notifier).state =
                                DateTime(month.year, month.month + 1),
                    ),
                  ],
                ),
              ),
            ),

            // 기록 목록
            Expanded(
              child: attendances.when(
                data: (records) {
                  if (records.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy_rounded, size: 56, color: AppColors.textHint),
                          const SizedBox(height: 16),
                          Text(
                            '기록이 없습니다',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final totalDays = records.length;
                  final totalHours = records.fold<double>(0, (sum, r) => sum + (r.workHours ?? 0));

                  return Column(
                    children: [
                      // 요약 카드
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            SummaryStatCard(
                              title: '출근일수',
                              value: '$totalDays일',
                              color: AppColors.checkIn,
                              icon: Icons.calendar_today_rounded,
                            ),
                            const SizedBox(width: 12),
                            SummaryStatCard(
                              title: '총 근무시간',
                              value: '${totalHours.toStringAsFixed(1)}h',
                              color: AppColors.primary,
                              icon: Icons.timer_rounded,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 리스트
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            final r = records[records.length - 1 - index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.checkIn.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: AppColors.checkIn,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dateFormat.format(r.checkInTime.toLocal()),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${timeFormat.format(r.checkInTime.toLocal())} ~ ${r.checkOutTime != null ? timeFormat.format(r.checkOutTime!.toLocal()) : '-'}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    r.workHours != null
                                        ? '${r.workHours!.toStringAsFixed(1)}h'
                                        : '-',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('오류: $e', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
