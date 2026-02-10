// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Attendance _$AttendanceFromJson(Map<String, dynamic> json) => _Attendance(
  id: json['id'] as String,
  workerId: json['worker_id'] as String,
  checkInTime: DateTime.parse(json['check_in_time'] as String),
  checkInLatitude: (json['check_in_latitude'] as num).toDouble(),
  checkInLongitude: (json['check_in_longitude'] as num).toDouble(),
  checkOutTime: json['check_out_time'] == null
      ? null
      : DateTime.parse(json['check_out_time'] as String),
  checkOutLatitude: (json['check_out_latitude'] as num?)?.toDouble(),
  checkOutLongitude: (json['check_out_longitude'] as num?)?.toDouble(),
  workHours: (json['work_hours'] as num?)?.toDouble(),
  status: json['status'] as String? ?? 'present',
  notes: json['notes'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AttendanceToJson(_Attendance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'worker_id': instance.workerId,
      'check_in_time': instance.checkInTime.toIso8601String(),
      'check_in_latitude': instance.checkInLatitude,
      'check_in_longitude': instance.checkInLongitude,
      'check_out_time': instance.checkOutTime?.toIso8601String(),
      'check_out_latitude': instance.checkOutLatitude,
      'check_out_longitude': instance.checkOutLongitude,
      'work_hours': instance.workHours,
      'status': instance.status,
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
