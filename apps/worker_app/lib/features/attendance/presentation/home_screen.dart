import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/action_button.dart';
import '../../../core/widgets/status_card.dart';
import '../../../core/navigation/nav_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../announcements/providers/announcement_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/attendance_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final worker = ref.read(authProvider).worker;
      if (worker != null) {
        ref.read(attendanceProvider.notifier).loadTodayAttendance(worker.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final attState = ref.watch(attendanceProvider);
    final worker = authState.worker;
    final siteNameAsync = ref.watch(workerSiteNameProvider);
    final siteName = siteNameAsync.valueOrNull ?? '';
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('MM월 dd일 (E)', 'ko');
    final now = DateTime.now();

    final isIdle = attState.status == AttendanceStatus.idle ||
        attState.status == AttendanceStatus.error;
    final isCheckedIn = attState.status == AttendanceStatus.checkedIn;
    final isCheckedOut = attState.status == AttendanceStatus.checkedOut;
    final isLoading = attState.status == AttendanceStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 헤더: 인사말 + 사업장 ──
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '안녕하세요,',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${worker?.name ?? ''}님',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (siteName.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            siteName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                dateFormat.format(now),
                style: const TextStyle(fontSize: 13, color: AppColors.textHint),
              ),

              const SizedBox(height: 20),

              // ── 현재 근무 상태 배너 ──
              _StatusBanner(
                status: attState.status,
                checkInTime: attState.todayAttendance != null
                    ? timeFormat.format(attState.todayAttendance!.checkInTime.toLocal())
                    : null,
                checkOutTime: attState.todayAttendance?.checkOutTime != null
                    ? timeFormat.format(attState.todayAttendance!.checkOutTime!.toLocal())
                    : null,
                workHours: attState.todayAttendance?.workHours,
              ),

              const SizedBox(height: 20),

              // ── 출근/퇴근/조퇴 3버튼 ──
              if (isLoading)
                const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Row(
                  children: [
                    ActionButton(
                      icon: Icons.login_rounded,
                      label: '출근',
                      gradientColors: [AppColors.checkIn, AppColors.checkInLight],
                      enabled: isIdle,
                      onTap: () => _showConfirmDialog(
                        title: '출근 확인',
                        message: '출근 처리하시겠습니까?',
                        icon: Icons.login_rounded,
                        color: AppColors.checkIn,
                        onConfirm: () {
                          final w = ref.read(authProvider).worker;
                          if (w != null) {
                            ref.read(attendanceProvider.notifier).checkIn(w.id);
                          }
                        },
                      ),
                    ),
                    ActionButton(
                      icon: Icons.logout_rounded,
                      label: '퇴근',
                      gradientColors: [AppColors.checkOut, AppColors.checkOutLight],
                      enabled: isCheckedIn,
                      onTap: () => _showConfirmDialog(
                        title: '퇴근 확인',
                        message: '퇴근 처리하시겠습니까?',
                        icon: Icons.logout_rounded,
                        color: AppColors.checkOut,
                        onConfirm: () => ref.read(attendanceProvider.notifier).checkOut(),
                      ),
                    ),
                    ActionButton(
                      icon: Icons.directions_run_rounded,
                      label: '조퇴',
                      gradientColors: [AppColors.earlyLeave, AppColors.earlyLeaveLight],
                      enabled: isCheckedIn,
                      onTap: () => _showEarlyLeaveDialog(),
                    ),
                  ],
                ),

              if (attState.errorMessage != null) ...[
                const SizedBox(height: 12),
                Builder(builder: (context) {
                  final needsSettings = attState.errorMessage!.startsWith('[OPEN_SETTINGS]');
                  final displayMsg = needsSettings
                      ? attState.errorMessage!.replaceFirst('[OPEN_SETTINGS]', '')
                      : attState.errorMessage!;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayMsg,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                        if (needsSettings) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => Geolocator.openAppSettings(),
                              icon: const Icon(Icons.settings, size: 18),
                              label: const Text('앱 설정에서 위치 권한 허용하기'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 24),

              // ── 오늘 출퇴근 상세 ──
              if (attState.todayAttendance != null) ...[
                Text(
                  '오늘의 근무 상세',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                StatusCard(
                  label: '출근 시간',
                  value: timeFormat.format(attState.todayAttendance!.checkInTime.toLocal()),
                  icon: Icons.login_rounded,
                  color: AppColors.checkIn,
                ),
                const SizedBox(height: 8),
                if (attState.todayAttendance!.checkOutTime != null) ...[
                  StatusCard(
                    label: '퇴근 시간',
                    value: timeFormat.format(attState.todayAttendance!.checkOutTime!.toLocal()),
                    icon: Icons.logout_rounded,
                    color: AppColors.checkOut,
                  ),
                  const SizedBox(height: 8),
                  StatusCard(
                    label: '총 근무시간',
                    value: '${attState.todayAttendance!.workHours?.toStringAsFixed(1) ?? '-'}시간',
                    icon: Icons.timer_rounded,
                    color: AppColors.primary,
                  ),
                ],
                const SizedBox(height: 24),
              ],

              // ── 공지사항 ──
              _AnnouncementSection(),

              const SizedBox(height: 24),

              // ── 퀵 액세스 ──
              Text(
                '바로가기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _QuickAccessCard(
                    icon: Icons.calendar_month_rounded,
                    label: '근태기록',
                    color: AppColors.checkOut,
                    onTap: () => ref.read(navIndexProvider.notifier).state = 1,
                  ),
                  const SizedBox(width: 12),
                  _QuickAccessCard(
                    icon: Icons.account_balance_wallet_rounded,
                    label: '급여조회',
                    color: AppColors.checkIn,
                    onTap: () => ref.read(navIndexProvider.notifier).state = 2,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: FilledButton.styleFrom(backgroundColor: color),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showEarlyLeaveDialog() {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.directions_run_rounded, color: AppColors.earlyLeave, size: 24),
              const SizedBox(width: 8),
              const Text('조퇴 신청'),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '조퇴 사유를 입력해주세요.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  onChanged: (_) => setDialogState(() {}),
                  validator: (v) => (v == null || v.trim().isEmpty) ? '사유를 입력해주세요' : null,
                  decoration: InputDecoration(
                    hintText: '예: 병원 방문, 개인 사유 등',
                    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.earlyLeave),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: reasonController.text.trim().isEmpty
                  ? null
                  : () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(context);
                        ref.read(attendanceProvider.notifier).earlyLeave(
                              reasonController.text.trim(),
                            );
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.earlyLeave,
              ),
              child: const Text('조퇴 처리'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 현재 근무 상태 배너 ──
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.workHours,
  });

  final AttendanceStatus status;
  final String? checkInTime;
  final String? checkOutTime;
  final double? workHours;

  @override
  Widget build(BuildContext context) {
    final (label, icon, colors, sub) = _statusInfo;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (status == AttendanceStatus.checkedIn && checkInTime != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  checkInTime!,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '출근',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          if (status == AttendanceStatus.checkedOut && workHours != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${workHours!.toStringAsFixed(1)}h',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '근무시간',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  (String, IconData, List<Color>, String) get _statusInfo {
    switch (status) {
      case AttendanceStatus.idle:
      case AttendanceStatus.error:
        return (
          '출근 전',
          Icons.wb_sunny_rounded,
          [const Color(0xFF94A3B8), const Color(0xFF64748B)],
          '출근 버튼을 눌러주세요',
        );
      case AttendanceStatus.checkedIn:
        return (
          '근무 중',
          Icons.work_rounded,
          [AppColors.checkIn, const Color(0xFF047857)],
          '현재 근무 중입니다',
        );
      case AttendanceStatus.checkedOut:
        return (
          '퇴근 완료',
          Icons.check_circle_rounded,
          [AppColors.checkOut, const Color(0xFF1D4ED8)],
          '오늘 하루도 수고하셨습니다',
        );
      case AttendanceStatus.loading:
        return (
          '처리 중...',
          Icons.hourglass_top_rounded,
          [AppColors.primary, AppColors.primaryDark],
          '잠시만 기다려주세요',
        );
    }
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 공지사항 섹션 ──
class _AnnouncementSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(workerAnnouncementsProvider);

    return announcementsAsync.when(
      data: (announcements) {
        if (announcements.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '공지사항',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...announcements.take(3).map((a) => _AnnouncementCard(
                  title: a['title'] as String? ?? '',
                  content: a['content'] as String? ?? '',
                  createdAt: a['created_at'] != null
                      ? DateTime.parse(a['created_at'] as String).toLocal()
                      : null,
                )),
          ],
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}

class _AnnouncementCard extends StatefulWidget {
  const _AnnouncementCard({
    required this.title,
    required this.content,
    this.createdAt,
  });

  final String title;
  final String content;
  final DateTime? createdAt;

  @override
  State<_AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<_AnnouncementCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final dateStr = widget.createdAt != null
        ? DateFormat('MM/dd').format(widget.createdAt!)
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.campaign, color: AppColors.primary, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: AppColors.textHint,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                Text(
                  widget.content,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
