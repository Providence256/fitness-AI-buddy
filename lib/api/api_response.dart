sealed class ApiResponse<T> {
  const ApiResponse();
}

class ApiSuccess<T> extends ApiResponse<T> {
  final T data;
  final Map<String, String> headers;
  final int statusCode;

  ApiSuccess({
    required this.data,
    required this.headers,
    required this.statusCode,
  });
}

class ApiError<T> extends ApiResponse<T> {
  final String message;
  final int? statusCode;
  final dynamic originalError;
  final NetworkErrorType type;

  ApiError({
    required this.message,
    this.statusCode,
    this.originalError,
    required this.type,
  });
}

enum NetworkErrorType {
  noConnection,
  timeout,
  notFound,
  unauthorized,
  serverError,
  badRequest,
  parseError,
  unknown,
}
