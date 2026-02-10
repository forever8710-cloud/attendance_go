// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'worker_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkerProfile {

 String get id; String get workerId; String? get company; String? get employeeId; String? get ssn; String? get gender; String? get address; String? get detailAddress; String? get email; String? get emergencyContact; String? get resumeFile; String? get employmentStatus; DateTime? get joinDate; DateTime? get leaveDate; String? get position; String? get title; String? get job; String? get photoUrl; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of WorkerProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkerProfileCopyWith<WorkerProfile> get copyWith => _$WorkerProfileCopyWithImpl<WorkerProfile>(this as WorkerProfile, _$identity);

  /// Serializes this WorkerProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkerProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.workerId, workerId) || other.workerId == workerId)&&(identical(other.company, company) || other.company == company)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.ssn, ssn) || other.ssn == ssn)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.address, address) || other.address == address)&&(identical(other.detailAddress, detailAddress) || other.detailAddress == detailAddress)&&(identical(other.email, email) || other.email == email)&&(identical(other.emergencyContact, emergencyContact) || other.emergencyContact == emergencyContact)&&(identical(other.resumeFile, resumeFile) || other.resumeFile == resumeFile)&&(identical(other.employmentStatus, employmentStatus) || other.employmentStatus == employmentStatus)&&(identical(other.joinDate, joinDate) || other.joinDate == joinDate)&&(identical(other.leaveDate, leaveDate) || other.leaveDate == leaveDate)&&(identical(other.position, position) || other.position == position)&&(identical(other.title, title) || other.title == title)&&(identical(other.job, job) || other.job == job)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,workerId,company,employeeId,ssn,gender,address,detailAddress,email,emergencyContact,resumeFile,employmentStatus,joinDate,leaveDate,position,title,job,photoUrl,createdAt,updatedAt]);

@override
String toString() {
  return 'WorkerProfile(id: $id, workerId: $workerId, company: $company, employeeId: $employeeId, ssn: $ssn, gender: $gender, address: $address, detailAddress: $detailAddress, email: $email, emergencyContact: $emergencyContact, resumeFile: $resumeFile, employmentStatus: $employmentStatus, joinDate: $joinDate, leaveDate: $leaveDate, position: $position, title: $title, job: $job, photoUrl: $photoUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $WorkerProfileCopyWith<$Res>  {
  factory $WorkerProfileCopyWith(WorkerProfile value, $Res Function(WorkerProfile) _then) = _$WorkerProfileCopyWithImpl;
@useResult
$Res call({
 String id, String workerId, String? company, String? employeeId, String? ssn, String? gender, String? address, String? detailAddress, String? email, String? emergencyContact, String? resumeFile, String? employmentStatus, DateTime? joinDate, DateTime? leaveDate, String? position, String? title, String? job, String? photoUrl, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$WorkerProfileCopyWithImpl<$Res>
    implements $WorkerProfileCopyWith<$Res> {
  _$WorkerProfileCopyWithImpl(this._self, this._then);

  final WorkerProfile _self;
  final $Res Function(WorkerProfile) _then;

/// Create a copy of WorkerProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workerId = null,Object? company = freezed,Object? employeeId = freezed,Object? ssn = freezed,Object? gender = freezed,Object? address = freezed,Object? detailAddress = freezed,Object? email = freezed,Object? emergencyContact = freezed,Object? resumeFile = freezed,Object? employmentStatus = freezed,Object? joinDate = freezed,Object? leaveDate = freezed,Object? position = freezed,Object? title = freezed,Object? job = freezed,Object? photoUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workerId: null == workerId ? _self.workerId : workerId // ignore: cast_nullable_to_non_nullable
as String,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String?,ssn: freezed == ssn ? _self.ssn : ssn // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,detailAddress: freezed == detailAddress ? _self.detailAddress : detailAddress // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,emergencyContact: freezed == emergencyContact ? _self.emergencyContact : emergencyContact // ignore: cast_nullable_to_non_nullable
as String?,resumeFile: freezed == resumeFile ? _self.resumeFile : resumeFile // ignore: cast_nullable_to_non_nullable
as String?,employmentStatus: freezed == employmentStatus ? _self.employmentStatus : employmentStatus // ignore: cast_nullable_to_non_nullable
as String?,joinDate: freezed == joinDate ? _self.joinDate : joinDate // ignore: cast_nullable_to_non_nullable
as DateTime?,leaveDate: freezed == leaveDate ? _self.leaveDate : leaveDate // ignore: cast_nullable_to_non_nullable
as DateTime?,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,job: freezed == job ? _self.job : job // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkerProfile].
extension WorkerProfilePatterns on WorkerProfile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkerProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkerProfile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkerProfile value)  $default,){
final _that = this;
switch (_that) {
case _WorkerProfile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkerProfile value)?  $default,){
final _that = this;
switch (_that) {
case _WorkerProfile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String workerId,  String? company,  String? employeeId,  String? ssn,  String? gender,  String? address,  String? detailAddress,  String? email,  String? emergencyContact,  String? resumeFile,  String? employmentStatus,  DateTime? joinDate,  DateTime? leaveDate,  String? position,  String? title,  String? job,  String? photoUrl,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkerProfile() when $default != null:
return $default(_that.id,_that.workerId,_that.company,_that.employeeId,_that.ssn,_that.gender,_that.address,_that.detailAddress,_that.email,_that.emergencyContact,_that.resumeFile,_that.employmentStatus,_that.joinDate,_that.leaveDate,_that.position,_that.title,_that.job,_that.photoUrl,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String workerId,  String? company,  String? employeeId,  String? ssn,  String? gender,  String? address,  String? detailAddress,  String? email,  String? emergencyContact,  String? resumeFile,  String? employmentStatus,  DateTime? joinDate,  DateTime? leaveDate,  String? position,  String? title,  String? job,  String? photoUrl,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _WorkerProfile():
return $default(_that.id,_that.workerId,_that.company,_that.employeeId,_that.ssn,_that.gender,_that.address,_that.detailAddress,_that.email,_that.emergencyContact,_that.resumeFile,_that.employmentStatus,_that.joinDate,_that.leaveDate,_that.position,_that.title,_that.job,_that.photoUrl,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String workerId,  String? company,  String? employeeId,  String? ssn,  String? gender,  String? address,  String? detailAddress,  String? email,  String? emergencyContact,  String? resumeFile,  String? employmentStatus,  DateTime? joinDate,  DateTime? leaveDate,  String? position,  String? title,  String? job,  String? photoUrl,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _WorkerProfile() when $default != null:
return $default(_that.id,_that.workerId,_that.company,_that.employeeId,_that.ssn,_that.gender,_that.address,_that.detailAddress,_that.email,_that.emergencyContact,_that.resumeFile,_that.employmentStatus,_that.joinDate,_that.leaveDate,_that.position,_that.title,_that.job,_that.photoUrl,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkerProfile implements WorkerProfile {
  const _WorkerProfile({required this.id, required this.workerId, this.company, this.employeeId, this.ssn, this.gender, this.address, this.detailAddress, this.email, this.emergencyContact, this.resumeFile, this.employmentStatus, this.joinDate, this.leaveDate, this.position, this.title, this.job, this.photoUrl, this.createdAt, this.updatedAt});
  factory _WorkerProfile.fromJson(Map<String, dynamic> json) => _$WorkerProfileFromJson(json);

@override final  String id;
@override final  String workerId;
@override final  String? company;
@override final  String? employeeId;
@override final  String? ssn;
@override final  String? gender;
@override final  String? address;
@override final  String? detailAddress;
@override final  String? email;
@override final  String? emergencyContact;
@override final  String? resumeFile;
@override final  String? employmentStatus;
@override final  DateTime? joinDate;
@override final  DateTime? leaveDate;
@override final  String? position;
@override final  String? title;
@override final  String? job;
@override final  String? photoUrl;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of WorkerProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkerProfileCopyWith<_WorkerProfile> get copyWith => __$WorkerProfileCopyWithImpl<_WorkerProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkerProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkerProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.workerId, workerId) || other.workerId == workerId)&&(identical(other.company, company) || other.company == company)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.ssn, ssn) || other.ssn == ssn)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.address, address) || other.address == address)&&(identical(other.detailAddress, detailAddress) || other.detailAddress == detailAddress)&&(identical(other.email, email) || other.email == email)&&(identical(other.emergencyContact, emergencyContact) || other.emergencyContact == emergencyContact)&&(identical(other.resumeFile, resumeFile) || other.resumeFile == resumeFile)&&(identical(other.employmentStatus, employmentStatus) || other.employmentStatus == employmentStatus)&&(identical(other.joinDate, joinDate) || other.joinDate == joinDate)&&(identical(other.leaveDate, leaveDate) || other.leaveDate == leaveDate)&&(identical(other.position, position) || other.position == position)&&(identical(other.title, title) || other.title == title)&&(identical(other.job, job) || other.job == job)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,workerId,company,employeeId,ssn,gender,address,detailAddress,email,emergencyContact,resumeFile,employmentStatus,joinDate,leaveDate,position,title,job,photoUrl,createdAt,updatedAt]);

@override
String toString() {
  return 'WorkerProfile(id: $id, workerId: $workerId, company: $company, employeeId: $employeeId, ssn: $ssn, gender: $gender, address: $address, detailAddress: $detailAddress, email: $email, emergencyContact: $emergencyContact, resumeFile: $resumeFile, employmentStatus: $employmentStatus, joinDate: $joinDate, leaveDate: $leaveDate, position: $position, title: $title, job: $job, photoUrl: $photoUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$WorkerProfileCopyWith<$Res> implements $WorkerProfileCopyWith<$Res> {
  factory _$WorkerProfileCopyWith(_WorkerProfile value, $Res Function(_WorkerProfile) _then) = __$WorkerProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String workerId, String? company, String? employeeId, String? ssn, String? gender, String? address, String? detailAddress, String? email, String? emergencyContact, String? resumeFile, String? employmentStatus, DateTime? joinDate, DateTime? leaveDate, String? position, String? title, String? job, String? photoUrl, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$WorkerProfileCopyWithImpl<$Res>
    implements _$WorkerProfileCopyWith<$Res> {
  __$WorkerProfileCopyWithImpl(this._self, this._then);

  final _WorkerProfile _self;
  final $Res Function(_WorkerProfile) _then;

/// Create a copy of WorkerProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workerId = null,Object? company = freezed,Object? employeeId = freezed,Object? ssn = freezed,Object? gender = freezed,Object? address = freezed,Object? detailAddress = freezed,Object? email = freezed,Object? emergencyContact = freezed,Object? resumeFile = freezed,Object? employmentStatus = freezed,Object? joinDate = freezed,Object? leaveDate = freezed,Object? position = freezed,Object? title = freezed,Object? job = freezed,Object? photoUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_WorkerProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workerId: null == workerId ? _self.workerId : workerId // ignore: cast_nullable_to_non_nullable
as String,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String?,ssn: freezed == ssn ? _self.ssn : ssn // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,detailAddress: freezed == detailAddress ? _self.detailAddress : detailAddress // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,emergencyContact: freezed == emergencyContact ? _self.emergencyContact : emergencyContact // ignore: cast_nullable_to_non_nullable
as String?,resumeFile: freezed == resumeFile ? _self.resumeFile : resumeFile // ignore: cast_nullable_to_non_nullable
as String?,employmentStatus: freezed == employmentStatus ? _self.employmentStatus : employmentStatus // ignore: cast_nullable_to_non_nullable
as String?,joinDate: freezed == joinDate ? _self.joinDate : joinDate // ignore: cast_nullable_to_non_nullable
as DateTime?,leaveDate: freezed == leaveDate ? _self.leaveDate : leaveDate // ignore: cast_nullable_to_non_nullable
as DateTime?,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,job: freezed == job ? _self.job : job // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
