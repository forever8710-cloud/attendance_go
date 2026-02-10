import 'package:freezed_annotation/freezed_annotation.dart';

part 'worker_profile.freezed.dart';
part 'worker_profile.g.dart';

@freezed
abstract class WorkerProfile with _$WorkerProfile {
  const factory WorkerProfile({
    required String id,
    required String workerId,
    String? company,
    String? employeeId,
    String? ssn,
    String? gender,
    String? address,
    String? detailAddress,
    String? email,
    String? emergencyContact,
    String? resumeFile,
    String? employmentStatus,
    DateTime? joinDate,
    DateTime? leaveDate,
    String? position,
    String? title,
    String? job,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _WorkerProfile;

  factory WorkerProfile.fromJson(Map<String, dynamic> json) =>
      _$WorkerProfileFromJson(json);
}
