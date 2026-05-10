import 'package:emailjs/emailjs.dart' as emailjs;
import 'package:flutter/material.dart';
import '../../constants/secrets.dart';
import '../../models/student_model.dart';

enum FeedbackType { feedback, bug }

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  static bool _initialized = false;

  FeedbackService._internal() {
    _initializeEmailJS();
  }

  factory FeedbackService() {
    return _instance;
  }

  static FeedbackService get instance => _instance;

  /// Initialize EmailJS with global settings (only once)
  static void _initializeEmailJS() {
    if (_initialized) return;

    emailjs.init(
      emailjs.Options(
        publicKey: emailjsPublicKey,
        privateKey: emailjsPrivateKey,
      ),
    );
    _initialized = true;
    debugPrint('✅ EmailJS initialized');
  }

  /// Send feedback or bug report via EmailJS
  Future<void> sendFeedback({
    required String feedbackType,
    required String subject,
    required String message,
    required Student student,
  }) async {
    try {
      // Format the current date/time
      final now = DateTime.now();
      final sentAt =
          '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}';

      // Create template parameters
      final Map<String, dynamic> templateParams = {
        'feedback_type': feedbackType,
        'student_name': student.name,
        'student_id': student.id,
        'student_faculty': student.faculty,
        'student_year': student.year.isNotEmpty ? student.year : 'N/A',
        'feedback_subject': subject,
        'message': message,
        'sent_at': sentAt,
      };
      
      // Send email via EmailJS
      await emailjs.send(
        emailjsServiceId,
        emailjsTemplateId,
        templateParams,
      );

      debugPrint('✅ Feedback sent successfully');
    } catch (error) {
      debugPrint('❌ Error sending feedback: $error');
      rethrow;
    }
  }
}
