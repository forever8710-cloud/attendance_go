class LocationException implements Exception {
  const LocationException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'LocationException($code): $message';
}

class PermissionDeniedException extends LocationException {
  const PermissionDeniedException() : super('위치 권한이 필요합니다', code: 'GPS_PERMISSION_DENIED');
}

class LocationTimeoutException extends LocationException {
  const LocationTimeoutException() : super('위치를 찾을 수 없습니다', code: 'GPS_TIMEOUT');
}

class LowAccuracyException extends LocationException {
  const LowAccuracyException() : super('GPS 정확도가 낮습니다', code: 'GPS_LOW_ACCURACY');
}

class OutOfRangeException extends LocationException {
  const OutOfRangeException() : super('사업장 반경을 벗어났습니다', code: 'OUT_OF_RANGE');
}
