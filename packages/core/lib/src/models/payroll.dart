import 'package:freezed_annotation/freezed_annotation.dart';

part 'payroll.freezed.dart';
part 'payroll.g.dart';

@freezed
abstract class Payroll with _$Payroll {
  const factory Payroll({
    required String id,
    required String workerId,
    required String yearMonth,
    required double totalWorkHours,
    required int totalWorkDays,
    required int baseSalary,
    @Default(0) int overtimePay,
    @Default(0) int holidayPay,
    required int totalSalary,
    @Default(false) bool isFinalized,
    DateTime? finalizedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Payroll;

  factory Payroll.fromJson(Map<String, dynamic> json) =>
      _$PayrollFromJson(json);
}
