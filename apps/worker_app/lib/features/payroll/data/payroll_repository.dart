import 'package:core/core.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_client/supabase_client.dart';

class PayrollRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  /// 급여 조회. 데이터 없으면 null, 네트워크/서버 오류면 예외 발생.
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
    } catch (e) {
      debugPrint('PayrollRepository.getPayroll error: $e');
      rethrow;
    }
  }
}
