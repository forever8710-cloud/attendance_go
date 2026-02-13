import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/payroll_repository.dart';

final payrollRepositoryProvider = Provider((ref) => PayrollRepository());

final payrollMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

final payrollProvider = FutureProvider<Payroll?>((ref) {
  final worker = ref.watch(authProvider).worker;
  if (worker == null) return null;

  final month = ref.watch(payrollMonthProvider);
  final yearMonth = '${month.year}-${month.month.toString().padLeft(2, '0')}';

  final repo = ref.watch(payrollRepositoryProvider);
  return repo.getPayroll(worker.id, yearMonth);
});
