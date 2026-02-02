import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance.freezed.dart';
part 'attendance.g.dart';

@freezed
abstract class Attendance with _$Attendance {
  const factory Attendance({
    required String id,
    required String workerId,
    required DateTime checkInTime,
    required double checkInLatitude,
    required double checkInLongitude,
    DateTime? checkOutTime,
    double? checkOutLatitude,
    double? checkOutLongitude,
    double? workHours,
    @Default('present') String status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Attendance;

  factory Attendance.fromJson(Map<String, dynamic> json) =>
      _$AttendanceFromJson(json);
}
