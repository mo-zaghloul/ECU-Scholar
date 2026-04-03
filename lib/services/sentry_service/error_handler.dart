import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'sentry_service.dart';

class ErrorHandler {
  /// Setup global error handlers
  static void setupGlobalErrorHandlers() {
    // Handle uncaught exceptions in Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _captureFlutterError(details);
    };

    // Handle uncaught exceptions outside Flutter
    PlatformDispatcher.instance.onError = (error, stack) {
      SentryService.captureException(
        error,
        stackTrace: stack,
        message: 'Platform dispatcher error',
      );
      return true;
    };
  }

  /// Capture Flutter specific errors
  static void _captureFlutterError(FlutterErrorDetails details) {
    SentryService.captureException(
      details.exception,
      stackTrace: details.stack,
      message: details.exceptionAsString(),
      extra: {
        'library': details.library,
        'context': details.context?.toString(),
      },
    );
  }

  /// Setup zone error handling
  static void setupZoneErrorHandling(VoidCallback appRunner) {
    runZonedGuarded(
      appRunner,
      (Object error, StackTrace stackTrace) {
        SentryService.captureException(
          error,
          stackTrace: stackTrace,
          message: 'Uncaught zone error',
        );
      },
    );
  }
}
