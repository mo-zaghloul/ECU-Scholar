import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_exception.dart';

/// Dio interceptor to handle and convert API errors to custom exceptions
class DioErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('❌ DioException: ${err.message}');
    debugPrint('   Status: ${err.response?.statusCode}');
    debugPrint('   Type: ${err.type}');

    final apiException = convertDioException(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: apiException,
        type: err.type,
        response: err.response,
      ),
    );
  }

  /// Convert DioException to custom ApiException
  static ApiException convertDioException(DioException dioErr) {
    String code = 'UNKNOWN_ERROR';
    String message = 'An unexpected error occurred';
    int? statusCode;

    switch (dioErr.type) {
      case DioExceptionType.badResponse:
        statusCode = dioErr.response?.statusCode;
        code = 'BAD_RESPONSE';
        message = _getBadResponseMessage(statusCode, dioErr.response?.data);
        break;

      case DioExceptionType.connectionTimeout:
        code = 'CONNECTION_TIMEOUT';
        message = 'Connection timeout. Please check your network.';
        break;

      case DioExceptionType.receiveTimeout:
        code = 'RECEIVE_TIMEOUT';
        message = 'Server response timeout. Please try again.';
        break;

      case DioExceptionType.sendTimeout:
        code = 'SEND_TIMEOUT';
        message = 'Request timeout. Please try again.';
        break;

      case DioExceptionType.cancel:
        code = 'CANCEL';
        message = 'Request was cancelled.';
        break;

      case DioExceptionType.connectionError:
        code = 'NETWORK_ERROR';
        message = 'Network error. Please check your internet connection.';
        break;

      case DioExceptionType.unknown:
        code = 'NETWORK_ERROR';
        message = dioErr.message ?? 'Network error occurred.';
        break;

      default:
        code = dioErr.type.toString();
        message = dioErr.message ?? 'An error occurred';
    }

    return ApiException(
      message: message,
      code: code,
      statusCode: statusCode,
      originalException: dioErr,
    );
  }

  /// Get user-friendly message for bad response status codes
  static String _getBadResponseMessage(int? statusCode, dynamic responseData) {
    // Try to extract error message from response body
    if (responseData is Map<String, dynamic>) {
      final message = responseData['detail'] ??
          responseData['message'] ??
          responseData['error'] ??
          responseData['msg'];
      if (message != null) {
        return message.toString();
      }
    }

    // Fallback to status code messages
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'You do not have permission to access this resource.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Conflict. This resource already exists.';
      case 422:
        return 'Invalid data provided.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
      case 503:
      case 504:
        return 'Server is temporarily unavailable. Please try again later.';
      default:
        return 'Request failed with status code: $statusCode';
    }
  }
}
