import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../services/remote_data_service/remote_data_service.dart';
import '../services/exceptions/api_exception.dart';

enum LoadingState { initial, loading, loaded, error }

class ScheduleListViewModel extends ChangeNotifier {
  /// Map of day number (1-7) to list of schedules
  /// 1 = Saturday, 2 = Sunday, ..., 7 = Friday (Egyptian week)
  Map<int, List<Schedule>> _weekSchedule = {};
  LoadingState _loadingState = LoadingState.initial;
  String? _errorMessage;

  LoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == LoadingState.loading;
  bool get hasError => _loadingState == LoadingState.error;
  Map<int, List<Schedule>> get weekSchedule => _weekSchedule;

  /// Fetch the full week schedule
  Future<void> fetchSchedules() async {
    _loadingState = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create fresh API service instance to ensure latest auth headers are used
      final apiService = BackendApiService();
      debugPrint('📅 ScheduleListViewModel: Fetching schedules...');
      _weekSchedule = await apiService.fetchWeekSchedule();
      _loadingState = LoadingState.loaded;
      debugPrint('✅ ScheduleListViewModel: Schedules loaded successfully (${_weekSchedule.length} days)');
      notifyListeners();
    } on ApiException catch (e) {
      debugPrint('❌ ScheduleListViewModel: API Error fetching schedules: ${e.message}');
      _errorMessage = e.userMessage;
      _loadingState = LoadingState.error;
      _weekSchedule = {};
      notifyListeners();
    } catch (e) {
      debugPrint('❌ ScheduleListViewModel: Error fetching schedules: $e');
      _errorMessage = e.toString();
      _loadingState = LoadingState.error;
      _weekSchedule = {};
      notifyListeners();
    }
  }

  /// Get schedules for a specific date
  List<Schedule> getSchedulesForDate(DateTime date) {
    final dayOfWeek = _convertToDayOfWeek(date);
    final schedules = _weekSchedule[dayOfWeek] ?? [];
    // Sort chronologically by start time (earliest first)
    schedules.sort((a, b) => a.compareStartTime(b));
    return schedules;
  }

  /// Get schedules for a specific day number (1-7)
  List<Schedule> getSchedulesForDay(int dayOfWeek) {
    final schedules = _weekSchedule[dayOfWeek] ?? [];
    // Sort chronologically by start time (earliest first)
    schedules.sort((a, b) => a.compareStartTime(b));
    return schedules;
  }

  /// Convert DateTime to Egyptian day of week (1 = Saturday, ..., 7 = Friday)
  int _convertToDayOfWeek(DateTime date) {
    // DateTime.weekday: 1 = Monday, ..., 7 = Sunday
    // Egyptian week: 1 = Saturday, 2 = Sunday, ..., 7 = Friday
    // Mapping: Sat=6->1, Sun=7->2, Mon=1->3, Tue=2->4, Wed=3->5, Thu=4->6, Fri=5->7
    final dartWeekday = date.weekday;
    switch (dartWeekday) {
      case DateTime.saturday:
        return 1;
      case DateTime.sunday:
        return 2;
      case DateTime.monday:
        return 3;
      case DateTime.tuesday:
        return 4;
      case DateTime.wednesday:
        return 5;
      case DateTime.thursday:
        return 6;
      case DateTime.friday:
        return 7;
      default:
        return 1;
    }
  }

  /// Get day name from day number
  String getDayName(int dayOfWeek) {
    return DaySchedule.getDayName(dayOfWeek);
  }

  /// Legacy getter for backwards compatibility
  List<Schedule> get schedules {
    // Return all schedules as flat list
    return _weekSchedule.values.expand((list) => list).toList();
  }
}
