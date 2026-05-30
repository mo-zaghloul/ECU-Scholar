import 'package:ecu_scholar/models/exam_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecu_scholar/constants/text_styles.dart';

class ExamCardWidget extends StatelessWidget {
  final Exam exam;
  final String countdownText;

  const ExamCardWidget({
    super.key,
    required this.exam,
    required this.countdownText,
  });

  /// Check if exam is today
  bool _isToday() {
    final now = DateTime.now();
    return exam.startDateTime.year == now.year &&
        exam.startDateTime.month == now.month &&
        exam.startDateTime.day == now.day;
  }

  /// Format date as "Mon Jun 1" for future exams
  String _formatDateWithDay() {
    return DateFormat('EEE, MMM d').format(exam.startDateTime);
  }

  /// Get the time display text (date + time or just time)
  String _getTimeDisplay() {
    if (_isToday()) {
      // Today: just show time
      return exam.timeRange;
    } else {
      // Future: show date · time
      return '${_formatDateWithDay()} · ${exam.timeRange}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.error, // App red accent
            width: 4,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course name and badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  exam.courseName,
                  style: AppTextStyles.subtitle1bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  exam.examType,
                  style: AppTextStyles.small11.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Time with optional date
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                _getTimeDisplay(),
                style: AppTextStyles.small12.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          // Location and countdown row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Hall and seat info
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.door_front_door_outlined,
                      size: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        exam.getLocationDisplay(),
                        style: AppTextStyles.small12.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Countdown chip
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.alarm,
                      size: 13,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      countdownText,
                      style: AppTextStyles.small12.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.error,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
