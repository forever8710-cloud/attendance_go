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
    this.siteId,
    this.siteName,
    this.isActive = true,
    this.createdAt,
    this.personalEmail,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final String? position;
  final String? siteId;
  final String? siteName;
  final bool isActive;
  final DateTime? createdAt;
  final String? personalEmail;
}

class AccountsRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<List<AccountRow>> getAccounts() async {
    // 관리자 계정 (role != 'worker') 조회
    final rows = await _supabase
        .from('workers')
        .select('id, name, phone, role, site_id, is_active, created_at, worker_profiles(email, position, personal_email), sites(name)')
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

      // sites도 UNIQUE FK → 객체 또는 배열
      final sites = row['sites'];
      final String? siteName;
      if (sites is Map<String, dynamic>) {
        siteName = sites['name'] as String?;
      } else if (sites is List && sites.isNotEmpty) {
        siteName = (sites.first as Map<String, dynamic>)['name'] as String?;
      } else {
        siteName = null;
      }

      return AccountRow(
        id: row['id'] as String,
        name: row['name'] as String,
        phone: row['phone'] as String,
        email: profile?['email'] as String?,
        role: row['role'] as String,
        position: profile?['position'] as String?,
        siteId: row['site_id'] as String?,
        siteName: siteName,
        isActive: row['is_active'] as bool? ?? true,
        createdAt: row['created_at'] != null ? DateTime.tryParse(row['created_at'] as String) : null,
        personalEmail: profile?['personal_email'] as String?,
      );
    }).toList();
  }

  Future<void> saveAccount(AccountRow account) async {
    final workerData = <String, dynamic>{
      'name': account.name,
      'phone': account.phone,
      'role': account.role,
      'is_active': account.isActive,
    };
    if (account.siteId != null) workerData['site_id'] = account.siteId;
    await _supabase.from('workers').update(workerData).eq('id', account.id);

    if (account.email != null || account.position != null || account.personalEmail != null) {
      final profileData = <String, dynamic>{
        'worker_id': account.id,
      };
      if (account.email != null) profileData['email'] = account.email;
      if (account.position != null) profileData['position'] = account.position;
      if (account.personalEmail != null) profileData['personal_email'] = account.personalEmail;
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
    String? personalEmail,
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
    if (personalEmail != null) body['personal_email'] = personalEmail;

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

  /// 가입정보 이메일 전송 (Edge Function: send-welcome-email)
  Future<void> sendWelcomeEmail({
    required String toEmail,
    required String name,
    required String loginEmail,
    String? password,
  }) async {
    final body = <String, dynamic>{
      'to_email': toEmail,
      'name': name,
      'login_email': loginEmail,
    };
    if (password != null) body['password'] = password;

    final response = await _supabase.functions.invoke(
      'send-welcome-email',
      body: body,
    );

    if (response.status != 200) {
      final errorData = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
      throw Exception(errorData['error'] ?? '이메일 전송에 실패했습니다');
    }
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

  /// 계정 완전 삭제 (worker_profiles → workers 순서로 삭제)
  Future<void> deleteAccount(String id) async {
    // worker_profiles 먼저 삭제 (FK 제약)
    await _supabase.from('worker_profiles').delete().eq('worker_id', id);
    // workers 삭제
    await _supabase.from('workers').delete().eq('id', id);
  }
}

final accountsRepositoryProvider = Provider((ref) => AccountsRepository());

final accountsProvider = FutureProvider<List<AccountRow>>((ref) {
  return ref.watch(accountsRepositoryProvider).getAccounts();
});
