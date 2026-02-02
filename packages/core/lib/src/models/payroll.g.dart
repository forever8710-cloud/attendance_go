// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Payroll _$PayrollFromJson(Map<String, dynamic> json) => _Payroll(
  id: json['id'] as String,
  workerId: json['workerId'] as String,
  yearMonth: json['yearMonth'] as String,
  totalWorkHours: (json['totalWorkHours'] as num).toDouble(),
  totalWorkDays: (json['totalWorkDays'] as num).toInt(),
  baseSalary: (json['baseSalary'] as num).toInt(),
  overtimePay: (json['overtimePay'] as num?)?.toInt() ?? 0,
  holidayPay: (json['holidayPay'] as num?)?.toInt() ?? 0,
  totalSalary: (json['totalSalary'] as num).toInt(),
  isFinalized: json['isFinalized'] as bool? ?? false,
  finalizedAt: json['finalizedAt'] == null
      ? null
      : DateTime.parse(json['finalizedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PayrollToJson(_Payroll instance) => <String, dynamic>{
  'id': instance.id,
  'workerId': instance.workerId,
  'yearMonth': instance.yearMonth,
  'totalWorkHours': instance.totalWorkHours,
  'totalWorkDays': instance.totalWorkDays,
  'baseSalary': instance.baseSalary,
  'overtimePay': instance.overtimePay,
  'holidayPay': instance.holidayPay,
  'totalSalary': instance.totalSalary,
  'isFinalized': instance.isFinalized,
  'finalizedAt': instance.finalizedAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
