/// Custom exception class for API errors
class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic originalException;

  ApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.originalException,
  });

  @override
  String toString() => message;

  /// Determine if error is network-related
  bool get isNetworkError =>
      code == 'NETWORK_ERROR' || originalException.toString().contains('SocketException');

  /// Determine if error is auth-related
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  /// Determine if error is server-related
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Get user-friendly error message
  String get userMessage {
    if (isNetworkError) {
      return 'No internet connection.\nPlease check your network.';
    }
    if (isAuthError) {
      return 'Session expired. Please login again.';
    }
    if (isServerError) {
      return 'Server is experiencing issues. Please try again later.';
    }
    if (statusCode == 404) {
      return 'Resource not found.';
    }
    if (statusCode == 429) {
      return 'Too many requests. Please try again later.';
    }
    return message;
  }
}
