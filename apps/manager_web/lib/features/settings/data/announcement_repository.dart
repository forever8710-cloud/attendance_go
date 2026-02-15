import 'package:supabase_client/supabase_client.dart';

class AnnouncementRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final rows = await _supabase
        .from('announcements')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<void> createAnnouncement({
    required String title,
    required String content,
    String? siteId,
  }) async {
    final userId = _supabase.client.auth.currentUser?.id;
    await _supabase.from('announcements').insert({
      'title': title,
      'content': content,
      if (siteId != null) 'site_id': siteId,
      'created_by': userId,
    });
  }

  Future<void> updateAnnouncement(
    String id, {
    String? title,
    String? content,
    String? siteId,
    bool? isActive,
  }) async {
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (content != null) updates['content'] = content;
    if (siteId != null) updates['site_id'] = siteId;
    if (isActive != null) updates['is_active'] = isActive;
    if (updates.isEmpty) return;

    await _supabase.from('announcements').update(updates).eq('id', id);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _supabase.from('announcements').delete().eq('id', id);
  }
}
