import 'package:ecu_scholar/view_models/exam_phase_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'exam_card.dart';
import 'upcoming_exam_card.dart';
import 'date_header.dart';

class ExamPhaseWidget extends StatelessWidget {
  const ExamPhaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header: "Monday" + "Today" pill + date
          DateHeaderWidget(
            date: DateTime.now(),
            showTodayPill: true,
          ),

          // Single Consumer for all exam phase data
          Consumer<ExamPhaseViewModel>(
            builder: (context, examViewModel, child) {
              // Show featured exam (next upcoming) if exists
              if (examViewModel.nextUpcomingExam != null) {
                return ExamCardWidget(
                  exam: examViewModel.nextUpcomingExam!,
                  countdownText: examViewModel.countdownText,
                );
              }

              // If no upcoming exams, show placeholder
              return Container(
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
              );
            },
          ),

          // Upcoming exams section - included in same Consumer
          Consumer<ExamPhaseViewModel>(
            builder: (context, examViewModel, child) {
              final upcomingExams = examViewModel.upcomingExams;

              if (upcomingExams.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No upcoming exams',
                    style: GoogleFonts.almarai(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }

              return Column(
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
                  ...upcomingExams.map(
                    (exam) => UpcomingExamCardWidget(exam: exam),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
