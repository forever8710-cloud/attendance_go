import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/worker_detail_repository.dart';

final workerDetailRepositoryProvider = Provider((ref) => WorkerDetailRepository());

/// 현재 보고 있는 년월
final detailYearMonthProvider = StateProvider<String>((ref) {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
});

/// 월별 근태 데이터 (workerId를 family 파라미터로)
final workerMonthlyAttendanceProvider = FutureProvider.family<List<WorkerMonthlyAttendanceRow>, String>(
  (ref, workerId) {
    final yearMonth = ref.watch(detailYearMonthProvider);
    return ref.watch(workerDetailRepositoryProvider).getMonthlyAttendance(workerId, yearMonth);
  },
);

/// 월별 요약 (workerId를 family 파라미터로)
final workerMonthlySummaryProvider = FutureProvider.family<WorkerMonthlySummary, String>(
  (ref, workerId) {
    final yearMonth = ref.watch(detailYearMonthProvider);
    return ref.watch(workerDetailRepositoryProvider).getMonthlySummary(workerId, yearMonth);
  },
);
