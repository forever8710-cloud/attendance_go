import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider((ref) => DashboardRepository());

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) {
  return ref.watch(dashboardRepositoryProvider).getTodaySummary('demo-site-id');
});

final todayAttendancesProvider = FutureProvider<List<WorkerAttendanceRow>>((ref) {
  return ref.watch(dashboardRepositoryProvider).getTodayAttendances('demo-site-id');
});
