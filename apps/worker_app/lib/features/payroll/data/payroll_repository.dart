import 'package:core/core.dart';
import 'package:supabase_client/supabase_client.dart';

class PayrollRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<Payroll?> getPayroll(String workerId, String yearMonth) async {
    try {
      final rows = await _supabase
          .from('payrolls')
          .select()
          .eq('worker_id', workerId)
          .eq('year_month', yearMonth)
          .limit(1);

      if (rows.isEmpty) return null;
      return Payroll.fromJson(rows.first);
    } catch (_) {
      return null;
    }
  }
}
