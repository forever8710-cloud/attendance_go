import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/payroll_provider.dart';

class PayrollScreen extends ConsumerWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(payrollMonthProvider);
    final payrollAsync = ref.watch(payrollProvider);
    final monthFormat = DateFormat('yyyy년 MM월');
    final currencyFormat = NumberFormat('#,###', 'ko');

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
                '급여조회',
                style: GoogleFonts.notoSansKr(
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
                      onPressed: () => ref.read(payrollMonthProvider.notifier).state =
                          DateTime(month.year, month.month - 1),
                    ),
                    Text(
                      monthFormat.format(month),
                      style: GoogleFonts.notoSansKr(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: month.month >= DateTime.now().month &&
                              month.year >= DateTime.now().year
                          ? null
                          : () => ref.read(payrollMonthProvider.notifier).state =
                                DateTime(month.year, month.month + 1),
                    ),
                  ],
                ),
              ),
            ),

            // 급여 내용
            Expanded(
              child: payrollAsync.when(
                data: (payroll) {
                  if (payroll == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 56,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '해당 월의 급여 내역이 없습니다',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '급여가 확정되면 여기에 표시됩니다',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 확정 상태 뱃지
                        if (!payroll.isFinalized)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    size: 18, color: Colors.amber[700]),
                                const SizedBox(width: 8),
                                Text(
                                  '아직 확정되지 않은 급여입니다',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.amber[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // 요약 카드 3개
                        Row(
                          children: [
                            _PayrollCard(
                              title: '기본급',
                              amount: currencyFormat.format(payroll.baseSalary),
                              color: AppColors.checkOut,
                              icon: Icons.payments_rounded,
                            ),
                            const SizedBox(width: 10),
                            _PayrollCard(
                              title: '연장수당',
                              amount: currencyFormat.format(payroll.overtimePay),
                              color: AppColors.earlyLeave,
                              icon: Icons.more_time_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // 총 지급액
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                '총 지급액',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${currencyFormat.format(payroll.totalSalary)}원',
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 근무 정보
                        Text(
                          '근무 정보',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow('출근일수', '${payroll.totalWorkDays}일'),
                        _InfoRow('총 근무시간', '${payroll.totalWorkHours.toStringAsFixed(1)}시간'),
                        if (payroll.holidayPay > 0)
                          _InfoRow('휴일수당', '${currencyFormat.format(payroll.holidayPay)}원'),
                        if (payroll.isFinalized && payroll.finalizedAt != null)
                          _InfoRow(
                            '확정일',
                            DateFormat('yyyy-MM-dd').format(payroll.finalizedAt!),
                          ),
                      ],
                    ),
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

class _PayrollCard extends StatelessWidget {
  const _PayrollCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String title;
  final String amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              '${amount}원',
              style: GoogleFonts.notoSansKr(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Text(
            value,
            style: GoogleFonts.notoSansKr(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
