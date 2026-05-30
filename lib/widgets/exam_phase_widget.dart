import 'package:ecu_scholar/view_models/exam_phase_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'exam_card.dart';
import 'upcoming_exam_card.dart';
import 'date_header.dart';
import 'shimmer_loading.dart' show ScheduleShimmer;

class ExamPhaseWidget extends StatelessWidget {
  const ExamPhaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<ExamPhaseViewModel>(
      builder: (context, examViewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header: Always visible, OUTSIDE RefreshIndicator
            DateHeaderWidget(
              date: DateTime.now(),
              showTodayPill: true,
            ),

            // Content area with RefreshIndicator
            Expanded(
              child: _buildContent(context, examViewModel, theme),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    ExamPhaseViewModel examViewModel,
    ThemeData theme,
  ) {
    // When loading, show shimmer (ScheduleShimmer is a ListView, use it directly!)
    if (examViewModel.loadingState == ExamPhaseLoadingState.loading) {
      return RefreshIndicator(
        onRefresh: () => examViewModel.fetchPhaseData(),
        child: const ScheduleShimmer(),
      );
    }

    // When error, show error message with fixed height
    if (examViewModel.loadingState == ExamPhaseLoadingState.error) {
      return RefreshIndicator(
        onRefresh: () => examViewModel.fetchPhaseData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Failed to load exams.\nPull to refresh.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.almarai(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Loaded state: Show exam content (has scrollable content)
    return RefreshIndicator(
      onRefresh: () => examViewModel.fetchPhaseData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured exam (next upcoming) if exists
            if (examViewModel.nextUpcomingExam != null)
              ExamCardWidget(
                exam: examViewModel.nextUpcomingExam!,
                countdownText: examViewModel.countdownText,
              )
            else
              // If no upcoming exams, show placeholder
              Container(
                width: double.infinity,
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    left: BorderSide(
                      color: theme.colorScheme.error,
                      width: 4,
                    ),
                  ),
                ),
                child: Text(
                  'No upcoming exams scheduled',
                  style: GoogleFonts.almarai(
                    fontSize: 14,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),

            // Upcoming exams section
            if (examViewModel.upcomingExams.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 20,
                      bottom: 10,
                    ),
                    child: Text(
                      'UPCOMING EXAMS',
                      style: GoogleFonts.almarai(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  ...examViewModel.upcomingExams.map(
                    (exam) => UpcomingExamCardWidget(exam: exam),
                  ),
                  const SizedBox(height: 16),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No upcoming exams',
                  style: GoogleFonts.almarai(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
