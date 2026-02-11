import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import 'attendance_history_screen.dart';

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
    final timeFormat = DateFormat('HH:mm:ss');

    return Scaffold(
      appBar: AppBar(
        title: const Text('WorkFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                worker?.name ?? '',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '서이천 사업장',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),

              // Status display
              if (attState.todayAttendance != null) ...[
                _buildTimeCard(
                  '출근',
                  timeFormat.format(attState.todayAttendance!.checkInTime),
                  Colors.green,
                ),
                if (attState.todayAttendance!.checkOutTime != null) ...[
                  const SizedBox(height: 12),
                  _buildTimeCard(
                    '퇴근',
                    timeFormat.format(attState.todayAttendance!.checkOutTime!),
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildTimeCard(
                    '근무시간',
                    '${attState.todayAttendance!.workHours?.toStringAsFixed(1)}시간',
                    Colors.indigo,
                  ),
                ],
                const SizedBox(height: 32),
              ],

              // Main button
              SizedBox(
                width: 200,
                height: 200,
                child: ElevatedButton(
                  onPressed: attState.status == AttendanceStatus.loading
                      ? null
                      : () => _handlePress(attState),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: _getButtonColor(attState.status),
                    foregroundColor: Colors.white,
                    elevation: 4,
                  ),
                  child: attState.status == AttendanceStatus.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_getButtonIcon(attState.status), size: 48),
                            const SizedBox(height: 8),
                            Text(
                              _getButtonText(attState.status),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),

              // 조퇴 버튼 (출근 후에만 활성화)
              if (attState.status == AttendanceStatus.checkedIn) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleEarlyLeave(),
                    icon: const Icon(Icons.directions_run, size: 20),
                    label: const Text('조퇴', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange[700],
                      side: BorderSide(color: Colors.orange[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],

              if (attState.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(attState.errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard(String label, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _handleEarlyLeave() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('조퇴 확인'),
        content: const Text('조퇴 처리하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(attendanceProvider.notifier).checkOut();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange[700]),
            child: const Text('조퇴'),
          ),
        ],
      ),
    );
  }

  void _handlePress(AttendanceState state) {
    final worker = ref.read(authProvider).worker;
    if (worker == null) return;

    if (state.status == AttendanceStatus.idle || state.status == AttendanceStatus.error) {
      ref.read(attendanceProvider.notifier).checkIn(worker.id);
    } else if (state.status == AttendanceStatus.checkedIn) {
      ref.read(attendanceProvider.notifier).checkOut();
    }
  }

  Color _getButtonColor(AttendanceStatus status) {
    return switch (status) {
      AttendanceStatus.idle || AttendanceStatus.error => Colors.green,
      AttendanceStatus.checkedIn => Colors.blue,
      AttendanceStatus.checkedOut => Colors.grey,
      _ => Colors.grey,
    };
  }

  IconData _getButtonIcon(AttendanceStatus status) {
    return switch (status) {
      AttendanceStatus.idle || AttendanceStatus.error => Icons.login,
      AttendanceStatus.checkedIn => Icons.logout,
      AttendanceStatus.checkedOut => Icons.check_circle,
      _ => Icons.hourglass_empty,
    };
  }

  String _getButtonText(AttendanceStatus status) {
    return switch (status) {
      AttendanceStatus.idle || AttendanceStatus.error => '출근',
      AttendanceStatus.checkedIn => '퇴근',
      AttendanceStatus.checkedOut => '완료',
      _ => '...',
    };
  }
}
