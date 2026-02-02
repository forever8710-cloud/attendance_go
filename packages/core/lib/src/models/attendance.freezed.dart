// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Attendance {

 String get id; String get workerId; DateTime get checkInTime; double get checkInLatitude; double get checkInLongitude; DateTime? get checkOutTime; double? get checkOutLatitude; double? get checkOutLongitude; double? get workHours; String get status; String? get notes; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceCopyWith<Attendance> get copyWith => _$AttendanceCopyWithImpl<Attendance>(this as Attendance, _$identity);

  /// Serializes this Attendance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Attendance&&(identical(other.id, id) || other.id == id)&&(identical(other.workerId, workerId) || other.workerId == workerId)&&(identical(other.checkInTime, checkInTime) || other.checkInTime == checkInTime)&&(identical(other.checkInLatitude, checkInLatitude) || other.checkInLatitude == checkInLatitude)&&(identical(other.checkInLongitude, checkInLongitude) || other.checkInLongitude == checkInLongitude)&&(identical(other.checkOutTime, checkOutTime) || other.checkOutTime == checkOutTime)&&(identical(other.checkOutLatitude, checkOutLatitude) || other.checkOutLatitude == checkOutLatitude)&&(identical(other.checkOutLongitude, checkOutLongitude) || other.checkOutLongitude == checkOutLongitude)&&(identical(other.workHours, workHours) || other.workHours == workHours)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workerId,checkInTime,checkInLatitude,checkInLongitude,checkOutTime,checkOutLatitude,checkOutLongitude,workHours,status,notes,createdAt,updatedAt);

@override
String toString() {
  return 'Attendance(id: $id, workerId: $workerId, checkInTime: $checkInTime, checkInLatitude: $checkInLatitude, checkInLongitude: $checkInLongitude, checkOutTime: $checkOutTime, checkOutLatitude: $checkOutLatitude, checkOutLongitude: $checkOutLongitude, workHours: $workHours, status: $status, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AttendanceCopyWith<$Res>  {
  factory $AttendanceCopyWith(Attendance value, $Res Function(Attendance) _then) = _$AttendanceCopyWithImpl;
@useResult
$Res call({
 String id, String workerId, DateTime checkInTime, double checkInLatitude, double checkInLongitude, DateTime? checkOutTime, double? checkOutLatitude, double? checkOutLongitude, double? workHours, String status, String? notes, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$AttendanceCopyWithImpl<$Res>
    implements $AttendanceCopyWith<$Res> {
  _$AttendanceCopyWithImpl(this._self, this._then);

  final Attendance _self;
  final $Res Function(Attendance) _then;

/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workerId = null,Object? checkInTime = null,Object? checkInLatitude = null,Object? checkInLongitude = null,Object? checkOutTime = freezed,Object? checkOutLatitude = freezed,Object? checkOutLongitude = freezed,Object? workHours = freezed,Object? status = null,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workerId: null == workerId ? _self.workerId : workerId // ignore: cast_nullable_to_non_nullable
as String,checkInTime: null == checkInTime ? _self.checkInTime : checkInTime // ignore: cast_nullable_to_non_nullable
as DateTime,checkInLatitude: null == checkInLatitude ? _self.checkInLatitude : checkInLatitude // ignore: cast_nullable_to_non_nullable
as double,checkInLongitude: null == checkInLongitude ? _self.checkInLongitude : checkInLongitude // ignore: cast_nullable_to_non_nullable
as double,checkOutTime: freezed == checkOutTime ? _self.checkOutTime : checkOutTime // ignore: cast_nullable_to_non_nullable
as DateTime?,checkOutLatitude: freezed == checkOutLatitude ? _self.checkOutLatitude : checkOutLatitude // ignore: cast_nullable_to_non_nullable
as double?,checkOutLongitude: freezed == checkOutLongitude ? _self.checkOutLongitude : checkOutLongitude // ignore: cast_nullable_to_non_nullable
as double?,workHours: freezed == workHours ? _self.workHours : workHours // ignore: cast_nullable_to_non_nullable
as double?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Attendance].
extension AttendancePatterns on Attendance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Attendance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Attendance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Attendance value)  $default,){
final _that = this;
switch (_that) {
case _Attendance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Attendance value)?  $default,){
final _that = this;
switch (_that) {
case _Attendance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String workerId,  DateTime checkInTime,  double checkInLatitude,  double checkInLongitude,  DateTime? checkOutTime,  double? checkOutLatitude,  double? checkOutLongitude,  double? workHours,  String status,  String? notes,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Attendance() when $default != null:
return $default(_that.id,_that.workerId,_that.checkInTime,_that.checkInLatitude,_that.checkInLongitude,_that.checkOutTime,_that.checkOutLatitude,_that.checkOutLongitude,_that.workHours,_that.status,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String workerId,  DateTime checkInTime,  double checkInLatitude,  double checkInLongitude,  DateTime? checkOutTime,  double? checkOutLatitude,  double? checkOutLongitude,  double? workHours,  String status,  String? notes,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Attendance():
return $default(_that.id,_that.workerId,_that.checkInTime,_that.checkInLatitude,_that.checkInLongitude,_that.checkOutTime,_that.checkOutLatitude,_that.checkOutLongitude,_that.workHours,_that.status,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String workerId,  DateTime checkInTime,  double checkInLatitude,  double checkInLongitude,  DateTime? checkOutTime,  double? checkOutLatitude,  double? checkOutLongitude,  double? workHours,  String status,  String? notes,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Attendance() when $default != null:
return $default(_that.id,_that.workerId,_that.checkInTime,_that.checkInLatitude,_that.checkInLongitude,_that.checkOutTime,_that.checkOutLatitude,_that.checkOutLongitude,_that.workHours,_that.status,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Attendance implements Attendance {
  const _Attendance({required this.id, required this.workerId, required this.checkInTime, required this.checkInLatitude, required this.checkInLongitude, this.checkOutTime, this.checkOutLatitude, this.checkOutLongitude, this.workHours, this.status = 'present', this.notes, this.createdAt, this.updatedAt});
  factory _Attendance.fromJson(Map<String, dynamic> json) => _$AttendanceFromJson(json);

@override final  String id;
@override final  String workerId;
@override final  DateTime checkInTime;
@override final  double checkInLatitude;
@override final  double checkInLongitude;
@override final  DateTime? checkOutTime;
@override final  double? checkOutLatitude;
@override final  double? checkOutLongitude;
@override final  double? workHours;
@override@JsonKey() final  String status;
@override final  String? notes;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceCopyWith<_Attendance> get copyWith => __$AttendanceCopyWithImpl<_Attendance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Attendance&&(identical(other.id, id) || other.id == id)&&(identical(other.workerId, workerId) || other.workerId == workerId)&&(identical(other.checkInTime, checkInTime) || other.checkInTime == checkInTime)&&(identical(other.checkInLatitude, checkInLatitude) || other.checkInLatitude == checkInLatitude)&&(identical(other.checkInLongitude, checkInLongitude) || other.checkInLongitude == checkInLongitude)&&(identical(other.checkOutTime, checkOutTime) || other.checkOutTime == checkOutTime)&&(identical(other.checkOutLatitude, checkOutLatitude) || other.checkOutLatitude == checkOutLatitude)&&(identical(other.checkOutLongitude, checkOutLongitude) || other.checkOutLongitude == checkOutLongitude)&&(identical(other.workHours, workHours) || other.workHours == workHours)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workerId,checkInTime,checkInLatitude,checkInLongitude,checkOutTime,checkOutLatitude,checkOutLongitude,workHours,status,notes,createdAt,updatedAt);

@override
String toString() {
  return 'Attendance(id: $id, workerId: $workerId, checkInTime: $checkInTime, checkInLatitude: $checkInLatitude, checkInLongitude: $checkInLongitude, checkOutTime: $checkOutTime, checkOutLatitude: $checkOutLatitude, checkOutLongitude: $checkOutLongitude, workHours: $workHours, status: $status, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AttendanceCopyWith<$Res> implements $AttendanceCopyWith<$Res> {
  factory _$AttendanceCopyWith(_Attendance value, $Res Function(_Attendance) _then) = __$AttendanceCopyWithImpl;
@override @useResult
$Res call({
 String id, String workerId, DateTime checkInTime, double checkInLatitude, double checkInLongitude, DateTime? checkOutTime, double? checkOutLatitude, double? checkOutLongitude, double? workHours, String status, String? notes, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$AttendanceCopyWithImpl<$Res>
    implements _$AttendanceCopyWith<$Res> {
  __$AttendanceCopyWithImpl(this._self, this._then);

  final _Attendance _self;
  final $Res Function(_Attendance) _then;

/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workerId = null,Object? checkInTime = null,Object? checkInLatitude = null,Object? checkInLongitude = null,Object? checkOutTime = freezed,Object? checkOutLatitude = freezed,Object? checkOutLongitude = freezed,Object? workHours = freezed,Object? status = null,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Attendance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workerId: null == workerId ? _self.workerId : workerId // ignore: cast_nullable_to_non_nullable
as String,checkInTime: null == checkInTime ? _self.checkInTime : checkInTime // ignore: cast_nullable_to_non_nullable
as DateTime,checkInLatitude: null == checkInLatitude ? _self.checkInLatitude : checkInLatitude // ignore: cast_nullable_to_non_nullable
as double,checkInLongitude: null == checkInLongitude ? _self.checkInLongitude : checkInLongitude // ignore: cast_nullable_to_non_nullable
as double,checkOutTime: freezed == checkOutTime ? _self.checkOutTime : checkOutTime // ignore: cast_nullable_to_non_nullable
as DateTime?,checkOutLatitude: freezed == checkOutLatitude ? _self.checkOutLatitude : checkOutLatitude // ignore: cast_nullable_to_non_nullable
as double?,checkOutLongitude: freezed == checkOutLongitude ? _self.checkOutLongitude : checkOutLongitude // ignore: cast_nullable_to_non_nullable
as double?,workHours: freezed == workHours ? _self.workHours : workHours // ignore: cast_nullable_to_non_nullable
as double?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
