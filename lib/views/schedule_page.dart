import 'package:ecu_scholar/views/grades_page.dart';
import 'package:ecu_scholar/views/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../view_models/schedule_list_viewmodel.dart';
import '../view_models/student_viewmodel.dart';
import '../widgets/shimmer_loading.dart';
import '../utils/schedule_tile.dart';
import '../constants/text_styles.dart';
import '../widgets/empty_schedulelist_widget.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late PageController _pageController;
  late DateTime _baseDate;
  int _currentPageIndex = 0;
  
  // Number of days to show (past and future)
  static const int _daysToShow = 14; // 2 weeks
  static const int _initialPage = 7; // Start at day 7 (today)

  @override
  void initState() {
    super.initState();
    _baseDate = DateTime.now();
    _currentPageIndex = _initialPage;
    _pageController = PageController(initialPage: _initialPage);
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Fetch student data if not already loaded (for returning users)
    final studentViewModel = Provider.of<StudentViewModel>(context, listen: false);
    if (studentViewModel.loadingState != StudentLoadingState.loaded) {
      studentViewModel.fetchStudentData();
    }
    // Fetch schedules
    await fetchSchedules();
  }

  Future<void> fetchSchedules() async {
    await Provider.of<ScheduleListViewModel>(context, listen: false)
        .fetchSchedules();
  }

  /// Get date for a specific page index
  DateTime _getDateForPage(int pageIndex) {
    final offset = pageIndex - _initialPage;
    return _baseDate.add(Duration(days: offset));
  }

  /// Get current displayed date
  DateTime get _currentDate => _getDateForPage(_currentPageIndex);

  /// Format day name (e.g., "Saturday")
  String _getDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Format date (e.g., "Feb 20")
  String _getFormattedDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// Check if date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header with swipe indicators
          _buildDateHeader(),
          
          // Schedule content with PageView
          Expanded(
            child: Consumer<ScheduleListViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const ScheduleShimmer();
                }

                // Handle error state with retry option
                if (viewModel.hasError) {
                  return _buildErrorWidget(viewModel.errorMessage);
                }

                return PageView.builder(
                  controller: _pageController,
                  itemCount: _daysToShow,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final date = _getDateForPage(index);
                    return _buildDaySchedule(viewModel, date);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    final date = _currentDate;
    final isToday = _isToday(date);
    
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 12, right: 12.0, left: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                _getDayName(date),
                style: AppTextStyles.headline1,
              ),
              if (isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Today',
                    style: GoogleFonts.almarai(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          Text(
            _getFormattedDate(date),
            style: AppTextStyles.bodyText1.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySchedule(ScheduleListViewModel viewModel, DateTime date) {
    final schedules = viewModel.getSchedulesForDate(date);
    
    if (schedules.isEmpty) {
      return RefreshIndicator(
        onRefresh: fetchSchedules,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: EmptySchedulelistWidget(),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchSchedules,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          return ScheduleTile(schedule: schedules[index]);
        },
      ),
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

  Widget _buildErrorWidget(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load schedule',
              style: GoogleFonts.almarai(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'An unexpected error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => fetchSchedules(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
