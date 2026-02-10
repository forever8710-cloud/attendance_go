// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Payroll _$PayrollFromJson(Map<String, dynamic> json) => _Payroll(
  id: json['id'] as String,
  workerId: json['worker_id'] as String,
  yearMonth: json['year_month'] as String,
  totalWorkHours: (json['total_work_hours'] as num).toDouble(),
  totalWorkDays: (json['total_work_days'] as num).toInt(),
  baseSalary: (json['base_salary'] as num).toInt(),
  overtimePay: (json['overtime_pay'] as num?)?.toInt() ?? 0,
  holidayPay: (json['holiday_pay'] as num?)?.toInt() ?? 0,
  totalSalary: (json['total_salary'] as num).toInt(),
  isFinalized: json['is_finalized'] as bool? ?? false,
  finalizedAt: json['finalized_at'] == null
      ? null
      : DateTime.parse(json['finalized_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PayrollToJson(_Payroll instance) => <String, dynamic>{
  'id': instance.id,
  'worker_id': instance.workerId,
  'year_month': instance.yearMonth,
  'total_work_hours': instance.totalWorkHours,
  'total_work_days': instance.totalWorkDays,
  'base_salary': instance.baseSalary,
  'overtime_pay': instance.overtimePay,
  'holiday_pay': instance.holidayPay,
  'total_salary': instance.totalSalary,
  'is_finalized': instance.isFinalized,
  'finalized_at': instance.finalizedAt?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
