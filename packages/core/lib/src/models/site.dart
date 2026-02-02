import 'package:freezed_annotation/freezed_annotation.dart';

part 'site.freezed.dart';
part 'site.g.dart';

@freezed
abstract class Site with _$Site {
  const factory Site({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    @Default(100) int radius,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Site;

  factory Site.fromJson(Map<String, dynamic> json) => _$SiteFromJson(json);
}
