import 'package:supabase_client/supabase_client.dart';

class WorkerAnnouncementRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  /// 활성 공지사항 조회 (전체 공지 + 내 사업장 공지)
  Future<List<Map<String, dynamic>>> getActiveAnnouncements(String? siteId) async {
    final rows = await _supabase
        .from('announcements')
        .select()
        .order('created_at', ascending: false)
        .limit(10);

    return List<Map<String, dynamic>>.from(rows).where((a) {
      final isActive = a['is_active'] as bool? ?? false;
      final announceSiteId = a['site_id'] as String?;
      return isActive && (announceSiteId == null || announceSiteId == siteId);
    }).toList();
  }

  /// Supabase Realtime 스트림 — 공지 변경 시 자동 갱신
  Stream<List<Map<String, dynamic>>> streamActiveAnnouncements(String? siteId) {
    return _supabase
        .from('announcements')
        .stream(primaryKey: ['id'])
        .map((rows) {
          final filtered = rows.where((a) {
            final isActive = a['is_active'] as bool? ?? false;
            final announceSiteId = a['site_id'] as String?;
            return isActive && (announceSiteId == null || announceSiteId == siteId);
          }).toList();
          filtered.sort((a, b) =>
              (b['created_at'] as String? ?? '').compareTo(a['created_at'] as String? ?? ''));
          return filtered;
        });
  }
}
