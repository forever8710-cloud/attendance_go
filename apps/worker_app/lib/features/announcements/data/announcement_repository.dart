import 'package:supabase_client/supabase_client.dart';

class WorkerAnnouncementRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  /// 활성 공지사항 조회 (전체 공지 + 내 사업장 공지)
  Future<List<Map<String, dynamic>>> getActiveAnnouncements(String? siteId) async {
    // RLS가 is_active=true만 허용하므로 별도 필터 불필요
    final rows = await _supabase
        .from('announcements')
        .select()
        .order('created_at', ascending: false)
        .limit(10);

    // 클라이언트 측에서 전체 공지(site_id=null) 또는 내 사업장 공지만 필터
    return List<Map<String, dynamic>>.from(rows).where((a) {
      final announceSiteId = a['site_id'] as String?;
      return announceSiteId == null || announceSiteId == siteId;
    }).toList();
  }
}
