// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Worker _$WorkerFromJson(Map<String, dynamic> json) => _Worker(
  id: json['id'] as String,
  siteId: json['site_id'] as String?,
  partId: json['part_id'] as String?,
  name: json['name'] as String,
  phone: json['phone'] as String,
  role: json['role'] as String? ?? 'worker',
  isActive: json['is_active'] as bool? ?? true,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$WorkerToJson(_Worker instance) => <String, dynamic>{
  'id': instance.id,
  'site_id': instance.siteId,
  'part_id': instance.partId,
  'name': instance.name,
  'phone': instance.phone,
  'role': instance.role,
  'is_active': instance.isActive,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
