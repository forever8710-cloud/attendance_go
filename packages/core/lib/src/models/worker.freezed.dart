// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'worker.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Worker {

 String get id; String get siteId; String? get partId; String get name; String get phone; String get role; bool get isActive; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Worker
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkerCopyWith<Worker> get copyWith => _$WorkerCopyWithImpl<Worker>(this as Worker, _$identity);

  /// Serializes this Worker to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Worker&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.partId, partId) || other.partId == partId)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,siteId,partId,name,phone,role,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'Worker(id: $id, siteId: $siteId, partId: $partId, name: $name, phone: $phone, role: $role, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $WorkerCopyWith<$Res>  {
  factory $WorkerCopyWith(Worker value, $Res Function(Worker) _then) = _$WorkerCopyWithImpl;
@useResult
$Res call({
 String id, String siteId, String? partId, String name, String phone, String role, bool isActive, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$WorkerCopyWithImpl<$Res>
    implements $WorkerCopyWith<$Res> {
  _$WorkerCopyWithImpl(this._self, this._then);

  final Worker _self;
  final $Res Function(Worker) _then;

/// Create a copy of Worker
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? siteId = null,Object? partId = freezed,Object? name = null,Object? phone = null,Object? role = null,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,partId: freezed == partId ? _self.partId : partId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Worker].
extension WorkerPatterns on Worker {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Worker value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Worker() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Worker value)  $default,){
final _that = this;
switch (_that) {
case _Worker():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Worker value)?  $default,){
final _that = this;
switch (_that) {
case _Worker() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String siteId,  String? partId,  String name,  String phone,  String role,  bool isActive,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Worker() when $default != null:
return $default(_that.id,_that.siteId,_that.partId,_that.name,_that.phone,_that.role,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String siteId,  String? partId,  String name,  String phone,  String role,  bool isActive,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Worker():
return $default(_that.id,_that.siteId,_that.partId,_that.name,_that.phone,_that.role,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String siteId,  String? partId,  String name,  String phone,  String role,  bool isActive,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Worker() when $default != null:
return $default(_that.id,_that.siteId,_that.partId,_that.name,_that.phone,_that.role,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Worker implements Worker {
  const _Worker({required this.id, required this.siteId, this.partId, required this.name, required this.phone, this.role = 'worker', this.isActive = true, this.createdAt, this.updatedAt});
  factory _Worker.fromJson(Map<String, dynamic> json) => _$WorkerFromJson(json);

@override final  String id;
@override final  String siteId;
@override final  String? partId;
@override final  String name;
@override final  String phone;
@override@JsonKey() final  String role;
@override@JsonKey() final  bool isActive;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Worker
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkerCopyWith<_Worker> get copyWith => __$WorkerCopyWithImpl<_Worker>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Worker&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.partId, partId) || other.partId == partId)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,siteId,partId,name,phone,role,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'Worker(id: $id, siteId: $siteId, partId: $partId, name: $name, phone: $phone, role: $role, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$WorkerCopyWith<$Res> implements $WorkerCopyWith<$Res> {
  factory _$WorkerCopyWith(_Worker value, $Res Function(_Worker) _then) = __$WorkerCopyWithImpl;
@override @useResult
$Res call({
 String id, String siteId, String? partId, String name, String phone, String role, bool isActive, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$WorkerCopyWithImpl<$Res>
    implements _$WorkerCopyWith<$Res> {
  __$WorkerCopyWithImpl(this._self, this._then);

  final _Worker _self;
  final $Res Function(_Worker) _then;

/// Create a copy of Worker
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? siteId = null,Object? partId = freezed,Object? name = null,Object? phone = null,Object? role = null,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Worker(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,partId: freezed == partId ? _self.partId : partId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
