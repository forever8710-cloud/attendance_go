import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

class AccountRow {
  AccountRow({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.role = 'worker',
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
}

class AccountsRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<List<AccountRow>> getAccounts() async {
    // 관리자 계정 (role != 'worker') 조회
    final rows = await _supabase
        .from('workers')
        .select('id, name, phone, role, is_active, created_at, worker_profiles(email)')
        .neq('role', 'worker');

    return (rows as List).map((row) {
      final profiles = row['worker_profiles'];
      final profile = (profiles is List && profiles.isNotEmpty) ? profiles.first : null;

      return AccountRow(
        id: row['id'] as String,
        name: row['name'] as String,
        phone: row['phone'] as String,
        email: profile?['email'] as String?,
        role: row['role'] as String,
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

    if (account.email != null) {
      await _supabase.from('worker_profiles').upsert({
        'worker_id': account.id,
        'email': account.email,
      }, onConflict: 'worker_id');
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
}

final accountsRepositoryProvider = Provider((ref) => AccountsRepository());

final accountsProvider = FutureProvider<List<AccountRow>>((ref) {
  return ref.watch(accountsRepositoryProvider).getAccounts();
});
