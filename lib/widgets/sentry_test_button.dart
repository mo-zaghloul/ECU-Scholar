import 'package:flutter/material.dart';
import 'package:ecu_scholar/services/sentry_service/sentry_service.dart';

/// Test widget to verify Sentry error catching
/// Usage: Add this to any screen during testing
class SentryTestButton extends StatelessWidget {
  const SentryTestButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Test 1: Divide by zero error
              try {
                final _ = 10 ~/ 0; // Intentional divide by zero
              } catch (e, stackTrace) {
                SentryService.captureException(
                  e,
                  stackTrace: stackTrace,
                  message: 'Test: Divide by zero error',
                );
              }
            },
            child: const Text('Test: Divide by Zero'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // Test 2: Null reference error
              try {
                String? nullStr;
                print(nullStr!.length);
              } catch (e, stackTrace) {
                SentryService.captureException(
                  e,
                  stackTrace: stackTrace,
                  message: 'Test: Null reference error',
                );
              }
            },
            child: const Text('Test: Null Reference'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // Test 3: Custom message logging
              SentryService.captureMessage(
                'Test message from app',
                extra: {'test_type': 'message_log', 'app_section': 'test_button'},
              );
            },
            child: const Text('Test: Log Message'),
          ),
        ],
      ),
    );
  }
}
