class RestfulRequestException implements Exception {
  final String message;
  final Object error;
  final StackTrace stackTrace;
  RestfulRequestException(
      {required this.message, required this.error, required this.stackTrace});
}

class InvalidServerResponseException implements Exception {
  final String message;
  final int? statusCode;
  final Object? error;
  final StackTrace? stackTrace;
  final dynamic response;
  InvalidServerResponseException(
      {required this.message,
      this.statusCode,
      this.error,
      this.stackTrace,
      this.response});
}

class ErrorMessageFromServer implements Exception {
  final String message;
  final int statusCode;
  ErrorMessageFromServer({required this.message, required this.statusCode});
}
