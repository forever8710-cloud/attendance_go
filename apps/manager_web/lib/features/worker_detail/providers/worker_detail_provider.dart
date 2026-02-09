import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/worker_detail_repository.dart';

final workerDetailRepositoryProvider = Provider((ref) => WorkerDetailRepository());

/// 현재 보고 있는 년월
final detailYearMonthProvider = StateProvider<String>((ref) {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
});

/// 월별 근태 데이터 (workerName을 family 파라미터로)
final workerMonthlyAttendanceProvider = FutureProvider.family<List<WorkerMonthlyAttendanceRow>, String>(
  (ref, workerName) {
    final yearMonth = ref.watch(detailYearMonthProvider);
    return ref.watch(workerDetailRepositoryProvider).getMonthlyAttendance(workerName, yearMonth);
  },
);

/// 월별 요약 (workerName을 family 파라미터로)
final workerMonthlySummaryProvider = FutureProvider.family<WorkerMonthlySummary, String>(
  (ref, workerName) {
    final yearMonth = ref.watch(detailYearMonthProvider);
    return ref.watch(workerDetailRepositoryProvider).getMonthlySummary(workerName, yearMonth);
  },
);
