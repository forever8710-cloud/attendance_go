class SupabaseServiceException implements Exception {
  const SupabaseServiceException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'SupabaseServiceException($code): $message';
}

class AuthException extends SupabaseServiceException {
  const AuthException(super.message, {super.code});
}

class DatabaseException extends SupabaseServiceException {
  const DatabaseException(super.message, {super.code});
}

class NetworkException extends SupabaseServiceException {
  const NetworkException(super.message, {super.code});
}
