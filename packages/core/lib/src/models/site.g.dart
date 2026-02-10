// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Site _$SiteFromJson(Map<String, dynamic> json) => _Site(
  id: json['id'] as String,
  name: json['name'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  radius: (json['radius'] as num?)?.toInt() ?? 100,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SiteToJson(_Site instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'radius': instance.radius,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
