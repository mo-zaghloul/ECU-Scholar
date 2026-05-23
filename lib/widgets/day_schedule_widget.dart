import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/schedule_list_viewmodel.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/date_picker_dialog.dart' as custom_dialog;
import 'date_header.dart';
import '../utils/schedule_tile.dart';
import '../widgets/empty_schedulelist_widget.dart';
import '../widgets/error_widget.dart' as error_widget;

class SchedulePageView extends StatefulWidget {
  const SchedulePageView({super.key});

  @override
  State<SchedulePageView> createState() => _SchedulePageViewState();
}

class _SchedulePageViewState extends State<SchedulePageView> {
  late PageController _pageController;
  late DateTime _baseDate;
  int _currentPageIndex = 0;

  // Infinite swiping: ±6 months from today (365 days total)
  // PageView lazily builds only visible pages (~3-5), so no performance impact
  static const int _daysToShow = 365; // Full ±6 months range
  static const int _initialPage = 182; // Start at day 182 (today in center)

  @override
  void initState() {
    super.initState();
    // Normalize to midnight to avoid time-based offset errors
    final now = DateTime.now();
    _baseDate = DateTime(now.year, now.month, now.day);
    _currentPageIndex = _initialPage;
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Get date for a specific page index
  DateTime _getDateForPage(int pageIndex) {
    final offset = pageIndex - _initialPage;
    return _baseDate.add(Duration(days: offset));
  }

  /// Get current displayed date
  DateTime get _currentDate => _getDateForPage(_currentPageIndex);

  /// Check if date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Show date picker dialog and jump to selected date
  Future<void> _openDatePicker() async {
    final minDate = _baseDate.subtract(Duration(days: _initialPage));
    final maxDate = _baseDate.add(Duration(days: _daysToShow - _initialPage - 1));

    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => custom_dialog.DatePickerDialog(
        initialDate: _currentDate,
        minDate: minDate,
        maxDate: maxDate,
      ),
    );

    if (selectedDate != null) {
      // Normalize selected date to midnight
      final normalizedSelected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

      // Calculate the page index - both dates are now at midnight so difference is exact
      final offset = normalizedSelected.difference(_baseDate).inDays;
      final pageIndex = _initialPage + offset + 1;

      // Animate to the selected date's page
      await _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      debugPrint('Jumped to date: ${normalizedSelected.toString()} (page $pageIndex)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header with swipe indicators
        DateHeaderWidget(
          date: _currentDate,
          showTodayPill: _isToday(_currentDate),
          onTap: _openDatePicker,
        ),

        // Schedule content with PageView
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _daysToShow,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final date = _getDateForPage(index);

              return Consumer<ScheduleListViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const ScheduleShimmer();
                  }

                  // Handle error state with retry option
                  if (viewModel.hasError) {
                    return _buildErrorWidget(viewModel.errorMessage);
                  }

                  return _buildDaySchedule(viewModel, date);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDaySchedule(ScheduleListViewModel viewModel, DateTime date) {
    final schedules = viewModel.getSchedulesForDate(date);

    if (schedules.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => Provider.of<ScheduleListViewModel>(context, listen: false)
            .fetchSchedules(),
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
      onRefresh: () => Provider.of<ScheduleListViewModel>(context, listen: false)
          .fetchSchedules(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          return ScheduleTile(schedule: schedules[index]);
        },
      ),
    );
  }

  Widget _buildErrorWidget(String? errorMessage) {
    final displayMessage = errorMessage ?? 'An unexpected error occurred.\nPull to refresh.';

    return RefreshIndicator(
      onRefresh: () => Provider.of<ScheduleListViewModel>(context, listen: false)
          .fetchSchedules(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: error_widget.ErrorWidget(
            message: displayMessage,
          ),
        ),
      ),
    );
  }
}
