import 'package:freezed_annotation/freezed_annotation.dart';

part 'part.freezed.dart';
part 'part.g.dart';

@freezed
abstract class Part with _$Part {
  const factory Part({
    required String id,
    required String name,
    required int hourlyWage,
    int? dailyWage,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Part;

  factory Part.fromJson(Map<String, dynamic> json) => _$PartFromJson(json);
}
