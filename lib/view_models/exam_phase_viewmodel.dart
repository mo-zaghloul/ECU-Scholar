import 'dart:async';
import 'package:ecu_scholar/models/exam_model.dart';
import 'package:flutter/material.dart';
import '../services/remote_data_service/remote_data_service.dart';

enum ExamPhaseLoadingState { initial, loading, loaded, error }

class ExamPhaseViewModel extends ChangeNotifier {
  ExamPhaseLoadingState _loadingState = ExamPhaseLoadingState.initial;
  String? _errorMessage;
  
  bool _isExamPhase = false;
  String _semester = '';
  String _academicYear = '';
  List<Exam> _exams = [];
  
  // Countdown timer for live updates
  Timer? _countdownTimer;
  String _countdownText = '--:--:--';
  bool _timerRunning = false;

  ExamPhaseViewModel() {
    _initializeDummyExams();
  }

  /// Initialize dummy exam data for development
  /// This will be replaced with real API data once backend is ready
void _initializeDummyExams() {
  _exams = [
    // Today at 3:00 PM
    // Exam(
    //   courseCode: 'CS401',
    //   courseName: 'Design & Analysis of Algorithms',
    //   startDateTime: DateTime(2026, 5, 23, 15, 0),
    //   endDateTime: DateTime(2026, 5, 23, 17, 0),
    //   examType: 'Final',
    //   location: null,
    //   seat: null,
    // ),

    // May 26, 2026 at 9:00 AM
    Exam(
      courseCode: 'SE402',
      courseName: 'Software Engineering (2)',
      startDateTime: DateTime(2026, 5, 26, 9, 0),
      endDateTime: DateTime(2026, 5, 26, 11, 0),
      examType: 'Final',
      location: null,
      seat: null,
    ),

    // May 28, 2026 at 9:00 AM
    Exam(
      courseCode: 'EE405',
      courseName: 'Electronic Design Automation',
      startDateTime: DateTime(2026, 5, 28, 9, 0),
      endDateTime: DateTime(2026, 5, 28, 11, 0),
      examType: 'Final',
      location: 'A 201',
      seat: '12',
    ),

    // May 30, 2026 at 9:00 AM
    Exam(
      courseCode: 'CE403',
      courseName: 'Control Engineering',
      startDateTime: DateTime(2026, 5, 30, 9, 0),
      endDateTime: DateTime(2026, 5, 30, 11, 0),
      examType: 'Final',
      location: 'C 305',
      seat: '20',
    ),
  ];
}

  // Getters
  ExamPhaseLoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == ExamPhaseLoadingState.loading;
  bool get isExamPhase => _isExamPhase;
  String get semester => _semester;
  String get academicYear => _academicYear;
  List<Exam> get exams => _exams;
  String get countdownText => _countdownText;

  /// Get next nearest upcoming exam (today or future)
  Exam? get nextUpcomingExam {
    try {
      final now = DateTime.now();
      // Find first exam that is today or in the future
      return _exams.firstWhere(
        (e) => e.startDateTime.isAfter(now) || _isSameDay(e.startDateTime, now),
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if date is today
  bool _isToday(DateTime dateTime) {
    final now = DateTime.now();
    return _isSameDay(dateTime, now);
  }

  /// Get upcoming exams (excluding the featured one, sorted by date)
  List<Exam> get upcomingExams {
    final featured = nextUpcomingExam;
    if (featured == null) return [];
    
    final now = DateTime.now();
    return _exams
        .where((e) =>
            (e.startDateTime.isAfter(DateTime(now.year, now.month, now.day)) ||
                _isSameDay(e.startDateTime, now)) &&
            e != featured)
        .toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Fetch exam phase data from API
  Future<void> fetchPhaseData() async {
    _loadingState = ExamPhaseLoadingState.loading;
    _errorMessage = null;
    notifyListeners();
    debugPrint('ExamPhaseViewModel: Fetching phase data...');

    try {
      final apiService = BackendApiService();
      final phaseData = await apiService.getUniPhase();

      _semester = phaseData['semester'] ?? '';
      _academicYear = phaseData['academic_year'] ?? '';
      _isExamPhase = phaseData['exams'] ?? false;

      debugPrint(
        '✅ ExamPhaseViewModel: Phase data loaded - '
        'isExam=$_isExamPhase, semester=$_semester',
      );

      _loadingState = ExamPhaseLoadingState.loaded;

      // Start countdown timer if in exam phase
      if (_isExamPhase && nextUpcomingExam != null) {
        debugPrint('ExamPhaseViewModel: Starting countdown timer for next exam');
        _startCountdownTimer();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('ExamPhaseViewModel: Error fetching phase data: $e');
      _errorMessage = e.toString();
      _loadingState = ExamPhaseLoadingState.error;
      notifyListeners();
    }
  }

  /// Start countdown timer for today's exam
  void _startCountdownTimer() {
    // Cancel existing timer if running
    if (_timerRunning && _countdownTimer != null) {
      _countdownTimer!.cancel();
    }

    _timerRunning = true;
    _updateCountdown(); // Initial update

    // Optimize refresh rate: seconds for today, minutes for future
    final exam = nextUpcomingExam;
    final refreshRate = exam != null && _isToday(exam.startDateTime)
        ? const Duration(seconds: 1)
        : const Duration(minutes: 1);

    _countdownTimer = Timer.periodic(refreshRate, (_) {
      _updateCountdown();
    });

    debugPrint('ExamPhaseViewModel: Countdown timer started (refresh: $refreshRate)');
  }

  /// Calculate and update countdown text
  /// Format: HH:MM:SS for today, Xd XXh XXm for future dates
  void _updateCountdown() {
    final exam = nextUpcomingExam;
    if (exam == null) {
      _countdownText = '--:--:--';
      notifyListeners();
      return;
    }

    try {
      final now = DateTime.now();
      final timeUntilExam = exam.startDateTime.difference(now);

      if (timeUntilExam.isNegative) {
        // Exam has passed
        _countdownText = '00:00:00';
        if (_timerRunning && _countdownTimer != null) {
          _countdownTimer!.cancel();
          _timerRunning = false;
          debugPrint('ExamPhaseViewModel: Exam time has passed, timer stopped');
        }
      } else {
        // Format based on whether exam is today or future
        if (_isToday(exam.startDateTime)) {
          // Today: HH:MM:SS format
          final hours = timeUntilExam.inHours;
          final minutes = timeUntilExam.inMinutes % 60;
          final seconds = timeUntilExam.inSeconds % 60;
          
          _countdownText = 
            '${hours.toString().padLeft(2, '0')}:'
            '${minutes.toString().padLeft(2, '0')}:'
            '${seconds.toString().padLeft(2, '0')}';
        } else {
          // Future: XdXXhXXm format
          final days = timeUntilExam.inDays;
          final remainingHours = timeUntilExam.inHours % 24;
          final remainingMinutes = timeUntilExam.inMinutes % 60;
          
          _countdownText = '${days}d ${remainingHours}h ${remainingMinutes}m';
        }
      }
    } catch (e) {
      debugPrint('ExamPhaseViewModel: Error calculating countdown: $e');
      _countdownText = '--:--:--';
    }

    notifyListeners();
  }

  @override
  void dispose() {
    if (_timerRunning && _countdownTimer != null) {
      _countdownTimer!.cancel();
      _timerRunning = false;
      debugPrint('ExamPhaseViewModel: Countdown timer disposed');
    }
    super.dispose();
  }
}
