import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

class AccountRow {
  AccountRow({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.role = 'worker',
    this.position,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final String? position;
  final bool isActive;
  final DateTime? createdAt;
}

class AccountsRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<List<AccountRow>> getAccounts() async {
    // 관리자 계정 (role != 'worker') 조회
    final rows = await _supabase
        .from('workers')
        .select('id, name, phone, role, is_active, created_at, worker_profiles(email, position)')
        .neq('role', 'worker');

    return (rows as List).map((row) {
      final profiles = row['worker_profiles'];
      // worker_profiles has UNIQUE on worker_id → PostgREST returns object, not array
      final Map<String, dynamic>? profile;
      if (profiles is Map<String, dynamic>) {
        profile = profiles;
      } else if (profiles is List && profiles.isNotEmpty) {
        profile = profiles.first as Map<String, dynamic>;
      } else {
        profile = null;
      }

      return AccountRow(
        id: row['id'] as String,
        name: row['name'] as String,
        phone: row['phone'] as String,
        email: profile?['email'] as String?,
        role: row['role'] as String,
        position: profile?['position'] as String?,
        isActive: row['is_active'] as bool? ?? true,
        createdAt: row['created_at'] != null ? DateTime.tryParse(row['created_at'] as String) : null,
      );
    }).toList();
  }

  Future<void> saveAccount(AccountRow account) async {
    await _supabase.from('workers').update({
      'name': account.name,
      'phone': account.phone,
      'role': account.role,
      'is_active': account.isActive,
    }).eq('id', account.id);

    if (account.email != null || account.position != null) {
      final profileData = <String, dynamic>{
        'worker_id': account.id,
      };
      if (account.email != null) profileData['email'] = account.email;
      if (account.position != null) profileData['position'] = account.position;
      await _supabase.from('worker_profiles').upsert(
        profileData,
        onConflict: 'worker_id',
      );
    }
  }

  /// Edge Function을 호출하여 Auth 유저 + workers + worker_profiles 생성
  Future<AccountRow> createAccount({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
    String? siteId,
    String? position,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'role': role,
    };
    if (siteId != null) body['site_id'] = siteId;
    if (position != null) body['position'] = position;

    final response = await _supabase.functions.invoke(
      'create-auth-user',
      body: body,
    );

    if (response.status != 200) {
      final errorData = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
      throw Exception(errorData['error'] ?? '계정 생성에 실패했습니다');
    }

    final data = response.data is String
        ? jsonDecode(response.data as String) as Map<String, dynamic>
        : response.data as Map<String, dynamic>;

    return AccountRow(
      id: data['id'] as String,
      name: data['name'] as String,
      phone: data['phone'] as String,
      email: data['email'] as String?,
      role: data['role'] as String,
      position: data['position'] as String?,
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  Future<void> toggleAccountStatus(String id) async {
    // 현재 상태 조회 후 토글
    final rows = await _supabase
        .from('workers')
        .select('is_active')
        .eq('id', id)
        .single();

    final currentStatus = rows['is_active'] as bool? ?? true;
    await _supabase.from('workers').update({
      'is_active': !currentStatus,
    }).eq('id', id);
  }
}

final accountsRepositoryProvider = Provider((ref) => AccountsRepository());

final accountsProvider = FutureProvider<List<AccountRow>>((ref) {
  return ref.watch(accountsRepositoryProvider).getAccounts();
});
