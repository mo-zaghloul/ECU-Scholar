import 'package:ecu_scholar/views/grades_page.dart';
import 'package:ecu_scholar/views/settings_page.dart';
import 'package:ecu_scholar/widgets/error_widget.dart' as error_widget;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../view_models/schedule_list_viewmodel.dart';
import '../view_models/student_viewmodel.dart';
import '../view_models/exam_phase_viewmodel.dart';
import '../widgets/exam_phase_widget.dart';
import '../widgets/day_schedule_widget.dart';
import '../widgets/shared_prefs_viewer.dart';
import '../widgets/shimmer_loading.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  void initState() {
    super.initState();
    // Defer data loading to after first frame to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      // Fetch student data if not already loaded (for returning users)
      final studentViewModel = Provider.of<StudentViewModel>(context, listen: false);
      if (studentViewModel.loadingState != StudentLoadingState.loaded) {
        await studentViewModel.fetchStudentData();
      }

      // Fetch exam phase data
      final examPhaseViewModel = Provider.of<ExamPhaseViewModel>(context, listen: false);
      await examPhaseViewModel.fetchPhaseData();

      // Fetch schedules
      await Provider.of<ScheduleListViewModel>(context, listen: false)
          .fetchSchedules();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        titleSpacing: 0,
        title: _buildAppBarTitle(context),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Grades',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GradesPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Consumer<ExamPhaseViewModel>(
        builder: (context, examViewModel, _) {
          // If loading or in exam phase, show exam UI (ExamPhaseWidget handles loading/error/content states)
          if (examViewModel.loadingState == ExamPhaseLoadingState.loading || 
              examViewModel.isExamPhase) {
            return const ExamPhaseWidget();
          }

          // Phase fetch failed and not in exam phase → show error with RefreshIndicator
          if (examViewModel.loadingState == ExamPhaseLoadingState.error) {
            return RefreshIndicator(
              onRefresh: () => examViewModel.fetchPhaseData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: error_widget.ErrorWidget(
                    message: examViewModel.errorMessage ?? 
                        'Failed to load exam phase.\nPull to refresh.',
                  ),
                ),
              ),
            );
          }

          // Otherwise show normal schedule view
          return const SchedulePageView();
        },
      ),
      floatingActionButton: kDebugMode ? const SharedPrefsViewerButton() : null,
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final student = Provider.of<StudentViewModel>(context).studentData;
    final firstName = student.name.split(' ').first;
    final title = _getTitleByFaculty(student.faculty);

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          // Logo
          SvgPicture.asset(
            isDark
                ? 'assets/images/logo/dark-theme-no-bg.svg'
                : 'assets/images/logo/light-theme-no-bg.svg',
            height: 36,
          ),
          const SizedBox(width: 12),
          // Greeting
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hello,',
                style: GoogleFonts.almarai(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              Text(
                '$title $firstName!',
                style: GoogleFonts.almarai(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTitleByFaculty(String faculty) {
    final lowerFaculty = faculty.toLowerCase();
    if (lowerFaculty.contains('engineering')) {
      return 'Eng.';
    } else if (lowerFaculty.contains('physical therapy') ||
        lowerFaculty.contains('pharmacy')) {
      return 'Dr.';
    } else if (lowerFaculty.contains('economics')) {
      return 'Ent.';
    } else {
      return '';
    }
  }
}
