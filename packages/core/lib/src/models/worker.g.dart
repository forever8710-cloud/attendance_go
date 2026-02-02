// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Worker _$WorkerFromJson(Map<String, dynamic> json) => _Worker(
  id: json['id'] as String,
  siteId: json['siteId'] as String,
  partId: json['partId'] as String?,
  name: json['name'] as String,
  phone: json['phone'] as String,
  role: json['role'] as String? ?? 'worker',
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$WorkerToJson(_Worker instance) => <String, dynamic>{
  'id': instance.id,
  'siteId': instance.siteId,
  'partId': instance.partId,
  'name': instance.name,
  'phone': instance.phone,
  'role': instance.role,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
