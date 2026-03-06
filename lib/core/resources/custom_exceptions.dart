enum CustomExceptionType {
  restfulRequest,
  invalidServerResponse,
  errorMessageFromServer,
  googleSignInError,
}

class CustomException implements Exception {
  final CustomExceptionType type;
  final String message;
  final int? statusCode;
  final Object? error;
  final StackTrace? stackTrace;
  final dynamic response;

  CustomException({
    required this.type,
    required this.message,
    this.statusCode,
    this.error,
    this.stackTrace,
    this.response,
  });
}
