import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/announcement_repository.dart';

final announcementRepositoryProvider = Provider((ref) => AnnouncementRepository());

final announcementsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(announcementRepositoryProvider).getAnnouncements();
});
