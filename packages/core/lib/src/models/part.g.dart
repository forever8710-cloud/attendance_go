// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Part _$PartFromJson(Map<String, dynamic> json) => _Part(
  id: json['id'] as String,
  name: json['name'] as String,
  hourlyWage: (json['hourlyWage'] as num).toInt(),
  dailyWage: (json['dailyWage'] as num?)?.toInt(),
  description: json['description'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PartToJson(_Part instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'hourlyWage': instance.hourlyWage,
  'dailyWage': instance.dailyWage,
  'description': instance.description,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
