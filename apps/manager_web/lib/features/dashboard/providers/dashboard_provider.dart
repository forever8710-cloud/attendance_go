import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider((ref) => DashboardRepository());

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) {
  final siteId = ref.watch(authProvider).worker?.siteId ?? '';
  return ref.watch(dashboardRepositoryProvider).getTodaySummary(siteId);
});

final todayAttendancesProvider = FutureProvider<List<WorkerAttendanceRow>>((ref) {
  final siteId = ref.watch(authProvider).worker?.siteId ?? '';
  return ref.watch(dashboardRepositoryProvider).getTodayAttendances(siteId);
});

/// 사이트 목록 프로바이더
final sitesProvider = FutureProvider<List<Map<String, String>>>((ref) {
  return ref.watch(dashboardRepositoryProvider).getSites();
});
