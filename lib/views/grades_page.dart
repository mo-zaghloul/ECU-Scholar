import 'package:ecu_scholar/view_models/grades_viewmodel.dart';
import 'package:ecu_scholar/view_models/student_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GradesViewModel>().loadGradesData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Academic Performance',
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
      body: Consumer<GradesViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // GPA Card
                _buildGpaCard(
                  context,
                  viewModel.gpaSummary.cumulativeGpa,
                  viewModel.gpaSummary.totalCredits,
                  viewModel.gpaState == GradesLoadingState.loading,
                ),

                const SizedBox(height: 24),

                // Academic Year Dropdown
                _buildYearDropdown(context, viewModel),

                const SizedBox(height: 16),

                // Grades Tables by Semester
                if (viewModel.gradesState == GradesLoadingState.loading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  )
                else if (viewModel.gradesState == GradesLoadingState.error)
                  _buildErrorWidget(viewModel.errorMessage)
                else
                  ...viewModel.orderedSemesters.map(
                    (semester) => _buildSemesterTable(
                      context,
                      viewModel,
                      semester,
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGpaCard(
    BuildContext context,
    double gpa,
    double totalCredits,
    bool isLoading,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFCE1407),
            const Color(0xFFCE1407).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCE1407).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Column(
              children: [
                Text(
                  'Cumulative GPA',
                  style: GoogleFonts.almarai(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  gpa.toStringAsFixed(2),
                  style: GoogleFonts.almarai(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hours: ${totalCredits.toInt()}',
                  style: GoogleFonts.almarai(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildYearDropdown(BuildContext context, GradesViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (viewModel.academicYears.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: viewModel.selectedAcademicYear,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colorScheme.primary,
          ),
          style: GoogleFonts.almarai(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
          dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          items: viewModel.academicYears.map((yearData) {
            return DropdownMenuItem<String>(
              value: yearData.academicYear,
              child: Text(yearData.academicYear),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              viewModel.selectAcademicYear(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSemesterTable(
    BuildContext context,
    GradesViewModel viewModel,
    String semester,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grades = viewModel.gradesBySemester[semester] ?? [];
    final totalHours = viewModel.getTotalHoursForSemester(semester);
    final semesterGpa = viewModel.getGpaForSemester(
      viewModel.selectedAcademicYear ?? '',
      semester,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Semester Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFCE1407).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              '$semester ${viewModel.selectedAcademicYear?.split('/').first ?? ''}',
              style: GoogleFonts.almarai(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFCE1407),
              ),
            ),
          ),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'Course',
                    style: GoogleFonts.almarai(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    'Grade',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.almarai(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                // SizedBox(
                //   width: 40,
                //   child: Text(
                //     'Hrs',
                //     textAlign: TextAlign.center,
                //     style: GoogleFonts.almarai(
                //       fontSize: 12,
                //       fontWeight: FontWeight.w600,
                //       color: Colors.grey,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),

          // Grade Rows
          ...grades.map((grade) => _buildGradeRow(context, grade)),

          // Total Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: semesterGpa != null
                      ? Text(
                          'GPA: ${semesterGpa.toStringAsFixed(2)}',
                          style: GoogleFonts.almarai(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Hours: ${totalHours.toInt()}',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.almarai(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeRow(BuildContext context, grade) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              grade.courseName,
              style: GoogleFonts.almarai(
                fontSize: 14,
                color: colorScheme.primary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              grade.gradeLetter,
              textAlign: TextAlign.center,
              style: GoogleFonts.almarai(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: grade.gradeColor,
              ),
            ),
          ),
          // SizedBox(
          //   width: 40,
          //   child: Text(
          //     grade.creditHours.toInt().toString(),
          //     textAlign: TextAlign.center,
          //     style: GoogleFonts.almarai(
          //       fontSize: 14,
          //       color: colorScheme.primary,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String? errorMessage) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Failed to load grades',
            style: GoogleFonts.almarai(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            errorMessage ?? 'Please try again later',
            textAlign: TextAlign.center,
            style: GoogleFonts.almarai(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
