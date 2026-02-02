// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payroll.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Payroll {

 String get id; String get workerId; String get yearMonth; double get totalWorkHours; int get totalWorkDays; int get baseSalary; int get overtimePay; int get holidayPay; int get totalSalary; bool get isFinalized; DateTime? get finalizedAt; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Payroll
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayrollCopyWith<Payroll> get copyWith => _$PayrollCopyWithImpl<Payroll>(this as Payroll, _$identity);

  /// Serializes this Payroll to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Payroll&&(identical(other.id, id) || other.id == id)&&(identical(other.workerId, workerId) || other.workerId == workerId)&&(identical(other.yearMonth, yearMonth) || other.yearMonth == yearMonth)&&(identical(other.totalWorkHours, totalWorkHours) || other.totalWorkHours == totalWorkHours)&&(identical(other.totalWorkDays, totalWorkDays) || other.totalWorkDays == totalWorkDays)&&(identical(other.baseSalary, baseSalary) || other.baseSalary == baseSalary)&&(identical(other.overtimePay, overtimePay) || other.overtimePay == overtimePay)&&(identical(other.holidayPay, holidayPay) || other.holidayPay == holidayPay)&&(identical(other.totalSalary, totalSalary) || other.totalSalary == totalSalary)&&(identical(other.isFinalized, isFinalized) || other.isFinalized == isFinalized)&&(identical(other.finalizedAt, finalizedAt) || other.finalizedAt == finalizedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workerId,yearMonth,totalWorkHours,totalWorkDays,baseSalary,overtimePay,holidayPay,totalSalary,isFinalized,finalizedAt,createdAt,updatedAt);

@override
String toString() {
  return 'Payroll(id: $id, workerId: $workerId, yearMonth: $yearMonth, totalWorkHours: $totalWorkHours, totalWorkDays: $totalWorkDays, baseSalary: $baseSalary, overtimePay: $overtimePay, holidayPay: $holidayPay, totalSalary: $totalSalary, isFinalized: $isFinalized, finalizedAt: $finalizedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PayrollCopyWith<$Res>  {
  factory $PayrollCopyWith(Payroll value, $Res Function(Payroll) _then) = _$PayrollCopyWithImpl;
@useResult
$Res call({
 String id, String workerId, String yearMonth, double totalWorkHours, int totalWorkDays, int baseSalary, int overtimePay, int holidayPay, int totalSalary, bool isFinalized, DateTime? finalizedAt, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$PayrollCopyWithImpl<$Res>
    implements $PayrollCopyWith<$Res> {
  _$PayrollCopyWithImpl(this._self, this._then);

  final Payroll _self;
  final $Res Function(Payroll) _then;

/// Create a copy of Payroll
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workerId = null,Object? yearMonth = null,Object? totalWorkHours = null,Object? totalWorkDays = null,Object? baseSalary = null,Object? overtimePay = null,Object? holidayPay = null,Object? totalSalary = null,Object? isFinalized = null,Object? finalizedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workerId: null == workerId ? _self.workerId : workerId // ignore: cast_nullable_to_non_nullable
as String,yearMonth: null == yearMonth ? _self.yearMonth : yearMonth // ignore: cast_nullable_to_non_nullable
as String,totalWorkHours: null == totalWorkHours ? _self.totalWorkHours : totalWorkHours // ignore: cast_nullable_to_non_nullable
as double,totalWorkDays: null == totalWorkDays ? _self.totalWorkDays : totalWorkDays // ignore: cast_nullable_to_non_nullable
as int,baseSalary: null == baseSalary ? _self.baseSalary : baseSalary // ignore: cast_nullable_to_non_nullable
as int,overtimePay: null == overtimePay ? _self.overtimePay : overtimePay // ignore: cast_nullable_to_non_nullable
as int,holidayPay: null == holidayPay ? _self.holidayPay : holidayPay // ignore: cast_nullable_to_non_nullable
as int,totalSalary: null == totalSalary ? _self.totalSalary : totalSalary // ignore: cast_nullable_to_non_nullable
as int,isFinalized: null == isFinalized ? _self.isFinalized : isFinalized // ignore: cast_nullable_to_non_nullable
as bool,finalizedAt: freezed == finalizedAt ? _self.finalizedAt : finalizedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Payroll].
extension PayrollPatterns on Payroll {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Payroll value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Payroll() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Payroll value)  $default,){
final _that = this;
switch (_that) {
case _Payroll():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Payroll value)?  $default,){
final _that = this;
switch (_that) {
case _Payroll() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String workerId,  String yearMonth,  double totalWorkHours,  int totalWorkDays,  int baseSalary,  int overtimePay,  int holidayPay,  int totalSalary,  bool isFinalized,  DateTime? finalizedAt,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Payroll() when $default != null:
return $default(_that.id,_that.workerId,_that.yearMonth,_that.totalWorkHours,_that.totalWorkDays,_that.baseSalary,_that.overtimePay,_that.holidayPay,_that.totalSalary,_that.isFinalized,_that.finalizedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String workerId,  String yearMonth,  double totalWorkHours,  int totalWorkDays,  int baseSalary,  int overtimePay,  int holidayPay,  int totalSalary,  bool isFinalized,  DateTime? finalizedAt,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Payroll():
return $default(_that.id,_that.workerId,_that.yearMonth,_that.totalWorkHours,_that.totalWorkDays,_that.baseSalary,_that.overtimePay,_that.holidayPay,_that.totalSalary,_that.isFinalized,_that.finalizedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String workerId,  String yearMonth,  double totalWorkHours,  int totalWorkDays,  int baseSalary,  int overtimePay,  int holidayPay,  int totalSalary,  bool isFinalized,  DateTime? finalizedAt,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Payroll() when $default != null:
return $default(_that.id,_that.workerId,_that.yearMonth,_that.totalWorkHours,_that.totalWorkDays,_that.baseSalary,_that.overtimePay,_that.holidayPay,_that.totalSalary,_that.isFinalized,_that.finalizedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Payroll implements Payroll {
  const _Payroll({required this.id, required this.workerId, required this.yearMonth, required this.totalWorkHours, required this.totalWorkDays, required this.baseSalary, this.overtimePay = 0, this.holidayPay = 0, required this.totalSalary, this.isFinalized = false, this.finalizedAt, this.createdAt, this.updatedAt});
  factory _Payroll.fromJson(Map<String, dynamic> json) => _$PayrollFromJson(json);

@override final  String id;
@override final  String workerId;
@override final  String yearMonth;
@override final  double totalWorkHours;
@override final  int totalWorkDays;
@override final  int baseSalary;
@override@JsonKey() final  int overtimePay;
@override@JsonKey() final  int holidayPay;
@override final  int totalSalary;
@override@JsonKey() final  bool isFinalized;
@override final  DateTime? finalizedAt;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Payroll
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayrollCopyWith<_Payroll> get copyWith => __$PayrollCopyWithImpl<_Payroll>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayrollToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Payroll&&(identical(other.id, id) || other.id == id)&&(identical(other.workerId, workerId) || other.workerId == workerId)&&(identical(other.yearMonth, yearMonth) || other.yearMonth == yearMonth)&&(identical(other.totalWorkHours, totalWorkHours) || other.totalWorkHours == totalWorkHours)&&(identical(other.totalWorkDays, totalWorkDays) || other.totalWorkDays == totalWorkDays)&&(identical(other.baseSalary, baseSalary) || other.baseSalary == baseSalary)&&(identical(other.overtimePay, overtimePay) || other.overtimePay == overtimePay)&&(identical(other.holidayPay, holidayPay) || other.holidayPay == holidayPay)&&(identical(other.totalSalary, totalSalary) || other.totalSalary == totalSalary)&&(identical(other.isFinalized, isFinalized) || other.isFinalized == isFinalized)&&(identical(other.finalizedAt, finalizedAt) || other.finalizedAt == finalizedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workerId,yearMonth,totalWorkHours,totalWorkDays,baseSalary,overtimePay,holidayPay,totalSalary,isFinalized,finalizedAt,createdAt,updatedAt);

@override
String toString() {
  return 'Payroll(id: $id, workerId: $workerId, yearMonth: $yearMonth, totalWorkHours: $totalWorkHours, totalWorkDays: $totalWorkDays, baseSalary: $baseSalary, overtimePay: $overtimePay, holidayPay: $holidayPay, totalSalary: $totalSalary, isFinalized: $isFinalized, finalizedAt: $finalizedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PayrollCopyWith<$Res> implements $PayrollCopyWith<$Res> {
  factory _$PayrollCopyWith(_Payroll value, $Res Function(_Payroll) _then) = __$PayrollCopyWithImpl;
@override @useResult
$Res call({
 String id, String workerId, String yearMonth, double totalWorkHours, int totalWorkDays, int baseSalary, int overtimePay, int holidayPay, int totalSalary, bool isFinalized, DateTime? finalizedAt, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$PayrollCopyWithImpl<$Res>
    implements _$PayrollCopyWith<$Res> {
  __$PayrollCopyWithImpl(this._self, this._then);

  final _Payroll _self;
  final $Res Function(_Payroll) _then;

/// Create a copy of Payroll
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workerId = null,Object? yearMonth = null,Object? totalWorkHours = null,Object? totalWorkDays = null,Object? baseSalary = null,Object? overtimePay = null,Object? holidayPay = null,Object? totalSalary = null,Object? isFinalized = null,Object? finalizedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Payroll(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workerId: null == workerId ? _self.workerId : workerId // ignore: cast_nullable_to_non_nullable
as String,yearMonth: null == yearMonth ? _self.yearMonth : yearMonth // ignore: cast_nullable_to_non_nullable
as String,totalWorkHours: null == totalWorkHours ? _self.totalWorkHours : totalWorkHours // ignore: cast_nullable_to_non_nullable
as double,totalWorkDays: null == totalWorkDays ? _self.totalWorkDays : totalWorkDays // ignore: cast_nullable_to_non_nullable
as int,baseSalary: null == baseSalary ? _self.baseSalary : baseSalary // ignore: cast_nullable_to_non_nullable
as int,overtimePay: null == overtimePay ? _self.overtimePay : overtimePay // ignore: cast_nullable_to_non_nullable
as int,holidayPay: null == holidayPay ? _self.holidayPay : holidayPay // ignore: cast_nullable_to_non_nullable
as int,totalSalary: null == totalSalary ? _self.totalSalary : totalSalary // ignore: cast_nullable_to_non_nullable
as int,isFinalized: null == isFinalized ? _self.isFinalized : isFinalized // ignore: cast_nullable_to_non_nullable
as bool,finalizedAt: freezed == finalizedAt ? _self.finalizedAt : finalizedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
