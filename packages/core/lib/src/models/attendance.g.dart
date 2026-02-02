// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Attendance _$AttendanceFromJson(Map<String, dynamic> json) => _Attendance(
  id: json['id'] as String,
  workerId: json['workerId'] as String,
  checkInTime: DateTime.parse(json['checkInTime'] as String),
  checkInLatitude: (json['checkInLatitude'] as num).toDouble(),
  checkInLongitude: (json['checkInLongitude'] as num).toDouble(),
  checkOutTime: json['checkOutTime'] == null
      ? null
      : DateTime.parse(json['checkOutTime'] as String),
  checkOutLatitude: (json['checkOutLatitude'] as num?)?.toDouble(),
  checkOutLongitude: (json['checkOutLongitude'] as num?)?.toDouble(),
  workHours: (json['workHours'] as num?)?.toDouble(),
  status: json['status'] as String? ?? 'present',
  notes: json['notes'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AttendanceToJson(_Attendance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workerId': instance.workerId,
      'checkInTime': instance.checkInTime.toIso8601String(),
      'checkInLatitude': instance.checkInLatitude,
      'checkInLongitude': instance.checkInLongitude,
      'checkOutTime': instance.checkOutTime?.toIso8601String(),
      'checkOutLatitude': instance.checkOutLatitude,
      'checkOutLongitude': instance.checkOutLongitude,
      'workHours': instance.workHours,
      'status': instance.status,
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
