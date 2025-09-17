import 'package:fitness_app/api/api_response.dart';
import 'package:fitness_app/error/error_handling_message.dart';
import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorHandlingMessage(
      error: ApiError(
        message: error.toString(),
        type: NetworkErrorType.unknown,
      ),
    );
  }
}
