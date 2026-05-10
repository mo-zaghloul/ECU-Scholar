import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern, sleek snackbar widget that can be used from anywhere in the app
class ModernSnackBar {
  /// Show a modern snackbar with custom icon, color, and message
  static void show({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color color,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.almarai(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Show error snackbar
  static void showError({
    required BuildContext context,
    required String message,
  }) {
    show(
      context: context,
      message: message,
      icon: Icons.error,
      color: Colors.red.shade600,
    );
  }

  /// Show success snackbar
  static void showSuccess({
    required BuildContext context,
    required String message,
  }) {
    show(
      context: context,
      message: message,
      icon: Icons.check_circle,
      color: Colors.green.shade600,
    );
  }

  /// Show info snackbar
  static void showInfo({
    required BuildContext context,
    required String message,
  }) {
    show(
      context: context,
      message: message,
      icon: Icons.info,
      color: Colors.blue.shade600,
    );
  }

  /// Show warning snackbar
  static void showWarning({
    required BuildContext context,
    required String message,
  }) {
    show(
      context: context,
      message: message,
      icon: Icons.warning,
      color: Colors.orange.shade600,
    );
  }
}
