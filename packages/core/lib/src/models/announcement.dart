import 'package:freezed_annotation/freezed_annotation.dart';

part 'announcement.freezed.dart';
part 'announcement.g.dart';

@freezed
abstract class Announcement with _$Announcement {
  const factory Announcement({
    required String id,
    required String title,
    required String content,
    String? siteId,
    String? createdBy,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Announcement;

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);
}
