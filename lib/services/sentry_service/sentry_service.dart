import 'package:sentry_flutter/sentry_flutter.dart';

class SentryService {
  /// Capture exception and log it to Sentry
  static Future<void> captureException(
    Object exception, {
    StackTrace? stackTrace,
    String? message,
    Map<String, dynamic>? extra,
  }) async {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (message != null) {
          scope.setTag('error_message', message);
        }
        if (extra != null) {
          for (final entry in extra.entries) {
            scope.setTag(entry.key, entry.value.toString());
          }
        }
      },
    );
  }

  /// Capture a message to Sentry
  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? extra,
  }) async {
    await Sentry.captureMessage(
      message,
      level: level,
      withScope: (scope) {
        if (extra != null) {
          for (final entry in extra.entries) {
            scope.setTag(entry.key, entry.value.toString());
          }
        }
      },
    );
  }

  /// Add breadcrumb for tracking user actions
  static Future<void> addBreadcrumb({
    required String message,
    String category = 'app',
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? data,
  }) async {
    await Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        level: level,
        data: data,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Add HTTP breadcrumb
  static Future<void> addHttpBreadcrumb({
    required String url,
    required String method,
    int? statusCode,
    Duration? requestDuration,
  }) async {
    await Sentry.addBreadcrumb(
      Breadcrumb.http(
        url: Uri.parse(url),
        method: method,
        statusCode: statusCode,
        requestDuration: requestDuration,
      ),
    );
  }

  /// Add user interaction breadcrumb
  static Future<void> addUserInteractionBreadcrumb({
    required String message,
    String subCategory = 'click',
  }) async {
    await Sentry.addBreadcrumb(
      Breadcrumb.userInteraction(
        message: message,
        subCategory: subCategory,
      ),
    );
  }
}
