import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fitness_app/api/api_response.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseurl = 'https://wger.de/api/v2';
  static const Duration _timeout = Duration(seconds: 15);

  static final http.Client _client = http.Client();

  static ApiError<T> _handleError<T>(dynamic error, {http.Response? response}) {
    return switch (error) {
      SocketException() => ApiError<T>(
        message: 'No internet Connection',
        originalError: error,
        type: NetworkErrorType.noConnection,
      ),
      TimeoutException() => ApiError<T>(
        message: 'Request timeout',
        type: NetworkErrorType.timeout,
        originalError: error,
      ),
      FormatException() => ApiError<T>(
        message: 'Invalid data format',
        type: NetworkErrorType.parseError,
        originalError: error,
      ),

      _ when response != null => switch (response.statusCode) {
        400 => ApiError<T>(
          message: 'Bad request',
          type: NetworkErrorType.badRequest,
          statusCode: response.statusCode,
        ),
        401 => ApiError<T>(
          message: 'Unauthorized',
          type: NetworkErrorType.unauthorized,
          statusCode: response.statusCode,
        ),
        404 => ApiError<T>(
          message: 'Not found',
          type: NetworkErrorType.notFound,
          statusCode: response.statusCode,
        ),
        500 => ApiError<T>(
          message: 'Server Error',
          type: NetworkErrorType.serverError,
          statusCode: response.statusCode,
        ),

        _ => ApiError<T>(
          message: 'HTTP ${response.statusCode}',
          type: NetworkErrorType.unknown,
          statusCode: response.statusCode,
        ),
      },

      _ => ApiError<T>(
        message: 'Unknown error',
        type: NetworkErrorType.unknown,
        originalError: error,
      ),
    };
  }

  // GET
  static Future<ApiResponse<T>> get<T>(
    String endPoint,
    T Function(dynamic json) parser,
  ) async {
    final url = '$_baseurl$endPoint';

    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
              'User-Agent': 'Flutter-fitness-Api-Buddy/1.0',
            },
          )
          .timeout(_timeout);

      return switch (response.statusCode) {
        >= 200 && < 300 => () {
          try {
            final jsonData = json.decode(response.body);
            final parseData = parser(jsonData);

            return ApiSuccess<T>(
              data: parseData,
              headers: response.headers,
              statusCode: response.statusCode,
            );
          } catch (parseError) {
            return _handleError<T>(parseError, response: response);
          }
        }(),

        _ => _handleError<T>('HTTP ${response.statusCode}', response: response),
      };
    } catch (e) {
      return _handleError<T>(e);
    }
  }
}
