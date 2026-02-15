import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/announcement_repository.dart';

final workerAnnouncementRepositoryProvider =
    Provider((ref) => WorkerAnnouncementRepository());

/// Worker App에서 볼 수 있는 활성 공지사항
final workerAnnouncementsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  final siteId = ref.watch(authProvider).worker?.siteId;
  return ref.watch(workerAnnouncementRepositoryProvider).getActiveAnnouncements(siteId);
});
