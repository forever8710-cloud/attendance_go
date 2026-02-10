import 'package:freezed_annotation/freezed_annotation.dart';

part 'worker.freezed.dart';
part 'worker.g.dart';

@freezed
abstract class Worker with _$Worker {
  const factory Worker({
    required String id,
    String? siteId,
    String? partId,
    required String name,
    required String phone,
    @Default('worker') String role,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Worker;

  factory Worker.fromJson(Map<String, dynamic> json) => _$WorkerFromJson(json);
}
