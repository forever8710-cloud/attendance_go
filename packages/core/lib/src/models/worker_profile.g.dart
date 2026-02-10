// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkerProfile _$WorkerProfileFromJson(Map<String, dynamic> json) =>
    _WorkerProfile(
      id: json['id'] as String,
      workerId: json['worker_id'] as String,
      company: json['company'] as String?,
      employeeId: json['employee_id'] as String?,
      ssn: json['ssn'] as String?,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      detailAddress: json['detail_address'] as String?,
      email: json['email'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      resumeFile: json['resume_file'] as String?,
      employmentStatus: json['employment_status'] as String?,
      joinDate: json['join_date'] == null
          ? null
          : DateTime.parse(json['join_date'] as String),
      leaveDate: json['leave_date'] == null
          ? null
          : DateTime.parse(json['leave_date'] as String),
      position: json['position'] as String?,
      title: json['title'] as String?,
      job: json['job'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$WorkerProfileToJson(_WorkerProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'worker_id': instance.workerId,
      'company': instance.company,
      'employee_id': instance.employeeId,
      'ssn': instance.ssn,
      'gender': instance.gender,
      'address': instance.address,
      'detail_address': instance.detailAddress,
      'email': instance.email,
      'emergency_contact': instance.emergencyContact,
      'resume_file': instance.resumeFile,
      'employment_status': instance.employmentStatus,
      'join_date': instance.joinDate?.toIso8601String(),
      'leave_date': instance.leaveDate?.toIso8601String(),
      'position': instance.position,
      'title': instance.title,
      'job': instance.job,
      'photo_url': instance.photoUrl,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
