class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Session expired or unauthorized'])
      : super(message: message, statusCode: 401);
}

class NotFoundException extends ApiException {
  NotFoundException([String message = 'Resource not found'])
      : super(message: message, statusCode: 404);
}

class NetworkException extends ApiException {
  NetworkException([String message = 'Please check your internet connection'])
      : super(message: message, statusCode: null);
}
