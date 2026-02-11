import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

/// Supabase에서 sites 목록 조회
final sitesProvider = FutureProvider<List<Site>>((ref) async {
  final supabase = ref.watch(supabaseServiceProvider);
  final response = await supabase.from('sites').select().order('name');
  return (response as List).map((e) => Site.fromJson(e)).toList();
});

/// Supabase에서 parts 목록 조회
final partsProvider = FutureProvider<List<Part>>((ref) async {
  final supabase = ref.watch(supabaseServiceProvider);
  final response = await supabase.from('parts').select().order('name');
  return (response as List).map((e) => Part.fromJson(e)).toList();
});

/// 센터 이름 목록 (UI 드롭다운용)
final siteNamesProvider = Provider<List<String>>((ref) {
  final sites = ref.watch(sitesProvider);
  return sites.whenOrNull(data: (list) => list.map((s) => s.name).toList()) ?? [];
});

/// 파트 이름 목록 (UI 드롭다운용)
final partNamesProvider = Provider<List<String>>((ref) {
  final parts = ref.watch(partsProvider);
  return parts.whenOrNull(data: (list) => list.map((p) => p.name).toList()) ?? [];
});

/// site name → site id 매핑
final siteIdByNameProvider = Provider<Map<String, String>>((ref) {
  final sites = ref.watch(sitesProvider);
  return sites.whenOrNull(
    data: (list) => {for (final s in list) s.name: s.id},
  ) ?? {};
});

/// part name → part id 매핑
final partIdByNameProvider = Provider<Map<String, String>>((ref) {
  final parts = ref.watch(partsProvider);
  return parts.whenOrNull(
    data: (list) => {for (final p in list) p.name: p.id},
  ) ?? {};
});

/// site id → site name 역매핑
final siteNameByIdProvider = Provider<Map<String, String>>((ref) {
  final sites = ref.watch(sitesProvider);
  return sites.whenOrNull(
    data: (list) => {for (final s in list) s.id: s.name},
  ) ?? {};
});

/// part id → part name 역매핑
final partNameByIdProvider = Provider<Map<String, String>>((ref) {
  final parts = ref.watch(partsProvider);
  return parts.whenOrNull(
    data: (list) => {for (final p in list) p.id: p.name},
  ) ?? {};
});
