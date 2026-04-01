import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum FeedbackType { feedback, bug }

class FeedbackPage extends StatefulWidget {
  final FeedbackType feedbackType;

  const FeedbackPage({
    super.key,
    required this.feedbackType,
  });

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  String get _pageTitle => widget.feedbackType == FeedbackType.bug
      ? 'Report a Bug'
      : 'Send Feedback';

  String get _subjectHint => widget.feedbackType == FeedbackType.bug
      ? 'Brief description of the bug'
      : 'What is your feedback about?';

  String get _messageHint => widget.feedbackType == FeedbackType.bug
      ? 'Please describe the bug in detail. Include steps to reproduce if possible.'
      : 'Share your thoughts, suggestions, or ideas to help us improve the app.';

  IconData get _headerIcon => widget.feedbackType == FeedbackType.bug
      ? Icons.bug_report_outlined
      : Icons.feedback_outlined;

  Color get _accentColor => widget.feedbackType == FeedbackType.bug
      ? const Color(0xFFFF9500)
      : const Color(0xFF34C759);

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    // TODO: Implement actual feedback submission (email, API, etc.)
    // For now, simulate a delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: _accentColor),
            const SizedBox(width: 8),
            const Text('Thank You!'),
          ],
        ),
        content: Text(
          widget.feedbackType == FeedbackType.bug
              ? 'Your bug report has been submitted. We\'ll look into it!'
              : 'Your feedback has been submitted. We appreciate your input!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to settings
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _pageTitle,
          style: GoogleFonts.almarai(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header icon and description
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _headerIcon,
                    size: 32,
                    color: _accentColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  widget.feedbackType == FeedbackType.bug
                      ? 'Found something wrong?\nLet us know!'
                      : 'We\'d love to hear\nyour thoughts!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.almarai(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Subject Field
              Container(
                decoration: BoxDecoration(
                  color: isDark ? colorScheme.secondary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _subjectController,
                  style: GoogleFonts.almarai(
                    color: colorScheme.primary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    hintText: _subjectHint,
                    labelStyle: GoogleFonts.almarai(color: Colors.grey),
                    hintStyle: GoogleFonts.almarai(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDark ? colorScheme.secondary : Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a subject';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Message Field
              Container(
                decoration: BoxDecoration(
                  color: isDark ? colorScheme.secondary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _messageController,
                  maxLines: 6,
                  style: GoogleFonts.almarai(
                    color: colorScheme.primary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Message',
                    hintText: _messageHint,
                    labelStyle: GoogleFonts.almarai(color: Colors.grey),
                    hintStyle: GoogleFonts.almarai(color: Colors.grey.shade400),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDark ? colorScheme.secondary : Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a message';
                    }
                    if (value.trim().length < 10) {
                      return 'Message should be at least 10 characters';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Submit',
                        style: GoogleFonts.almarai(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
