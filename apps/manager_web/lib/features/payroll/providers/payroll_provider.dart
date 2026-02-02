import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/payroll_repository.dart';

final payrollRepositoryProvider = Provider((ref) => PayrollRepository());

final selectedYearMonthProvider = StateProvider<String>((ref) {
  final now = DateTime.now();
  final prev = DateTime(now.year, now.month - 1);
  return '${prev.year}-${prev.month.toString().padLeft(2, '0')}';
});

final payrollDataProvider = FutureProvider<List<PayrollRow>?>((ref) async {
  // Returns null until user clicks "generate"
  return null;
});
