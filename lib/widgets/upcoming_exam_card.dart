import 'package:ecu_scholar/models/exam_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecu_scholar/constants/text_styles.dart';

class UpcomingExamCardWidget extends StatelessWidget {
  final Exam exam;

  const UpcomingExamCardWidget({
    super.key,
    required this.exam,
  });

  /// Format date as "Thu, Jun 4"
  String _formatDate() {
    return DateFormat('EEE, MMM d').format(exam.startDateTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - course name and date/time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.courseName,
                  style: AppTextStyles.small13w500.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate()} · ${exam.startTimeRange}',
                  style: AppTextStyles.small12.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Right side - days remaining and location
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${exam.daysRemaining} day${exam.daysRemaining == 1 ? '' : 's'}',
                style: AppTextStyles.small13w500.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                exam.getLocationDisplay(),
                style: AppTextStyles.small11.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
