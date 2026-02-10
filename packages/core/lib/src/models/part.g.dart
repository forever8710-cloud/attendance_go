// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Part _$PartFromJson(Map<String, dynamic> json) => _Part(
  id: json['id'] as String,
  name: json['name'] as String,
  hourlyWage: (json['hourly_wage'] as num).toInt(),
  dailyWage: (json['daily_wage'] as num?)?.toInt(),
  description: json['description'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PartToJson(_Part instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'hourly_wage': instance.hourlyWage,
  'daily_wage': instance.dailyWage,
  'description': instance.description,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
