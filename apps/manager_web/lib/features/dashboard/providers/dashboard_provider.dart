import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/utils/permissions.dart';
import '../data/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider((ref) => DashboardRepository());

/// TTS 음성 알림 ON/OFF 토글
final ttsEnabledProvider = StateProvider<bool>((ref) => true);

/// Realtime 이벤트 발생 시 증가 → FutureProvider 자동 리페치
final dashboardRefreshProvider = StateProvider<int>((ref) => 0);

/// system_admin / owner → 전체 사이트 (siteId='')
/// center_manager → 자기 사이트만
String _effectiveSiteId(Ref ref) {
  final authState = ref.watch(authProvider);
  final role = authState.role;
  if (canAccessAllSites(role)) return '';
  return authState.worker?.siteId ?? '';
}

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) {
  ref.watch(dashboardRefreshProvider); // Realtime 트리거
  final siteId = _effectiveSiteId(ref);
  return ref.watch(dashboardRepositoryProvider).getTodaySummary(siteId);
});

final todayAttendancesProvider = FutureProvider<List<WorkerAttendanceRow>>((ref) {
  ref.watch(dashboardRefreshProvider); // Realtime 트리거
  final siteId = _effectiveSiteId(ref);
  return ref.watch(dashboardRepositoryProvider).getTodayAttendances(siteId);
});

final weeklyTrendProvider = FutureProvider<List<DailyAttendanceStat>>((ref) {
  final siteId = _effectiveSiteId(ref);
  return ref.watch(dashboardRepositoryProvider).getWeeklyTrend(siteId);
});

/// 사이트 목록 프로바이더
final sitesProvider = FutureProvider<List<Map<String, String>>>((ref) {
  return ref.watch(dashboardRepositoryProvider).getSites();
});
