import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';
import '../../auth/providers/auth_provider.dart';

class WorkerProfile {
  const WorkerProfile({
    this.ssn,
    this.address,
    this.bank,
    this.accountNumber,
  });

  final String? ssn;
  final String? address;
  final String? bank;
  final String? accountNumber;
}

final workerProfileProvider = FutureProvider<WorkerProfile?>((ref) async {
  final worker = ref.watch(authProvider).worker;
  if (worker == null) return null;

  try {
    final rows = await SupabaseService.instance
        .from('worker_profiles')
        .select()
        .eq('worker_id', worker.id)
        .limit(1);

    if (rows.isEmpty) return const WorkerProfile();

    final data = rows.first;
    return WorkerProfile(
      ssn: data['ssn'] as String?,
      address: data['address'] as String?,
      bank: data['bank'] as String?,
      accountNumber: data['account_number'] as String?,
    );
  } catch (_) {
    return const WorkerProfile();
  }
});

/// 사이트명 프로바이더
final workerSiteNameProvider = FutureProvider<String>((ref) async {
  final worker = ref.watch(authProvider).worker;
  if (worker == null || worker.siteId == null) return '';

  try {
    final row = await SupabaseService.instance
        .from('sites')
        .select('name')
        .eq('id', worker.siteId!)
        .single();
    return row['name'] as String? ?? '';
  } catch (_) {
    return '';
  }
});

/// 파트명 프로바이더
final workerPartNameProvider = FutureProvider<String>((ref) async {
  final worker = ref.watch(authProvider).worker;
  if (worker == null || worker.partId == null) return '';

  try {
    final row = await SupabaseService.instance
        .from('parts')
        .select('name')
        .eq('id', worker.partId!)
        .single();
    return row['name'] as String? ?? '';
  } catch (_) {
    return '';
  }
});
