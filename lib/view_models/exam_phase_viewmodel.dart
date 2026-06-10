import 'dart:async';
import 'package:collection/collection.dart';
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
    final now = DateTime.now();
    return _exams.firstWhereOrNull(
      (e) => e.endDateTime.isAfter(now),
    );
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
    
    return _exams
        .where((e) => e.endDateTime.isAfter(DateTime.now()) 
                  && e.examId != featured.examId)
        .toList(); // already sorted from load
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

    try {
      final apiService = BackendApiService();

      final phaseData = await apiService.getPhase();
      _semester     = phaseData.semester;
      _academicYear = phaseData.academicYear;
      _isExamPhase  = phaseData.isExamPhase;

      if (_isExamPhase) {
        try {
          _exams = await apiService.getPhaseExams();
          debugPrint('✅ ${_exams.length} exams loaded');
        } catch (e) {
          debugPrint('⚠️ Failed to load exams: $e');
          _exams = [];
        }
      } else {
        _exams = [];
      }

      _loadingState = ExamPhaseLoadingState.loaded;

      if (_isExamPhase && nextUpcomingExam != null) {
        _startCountdownTimer();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error fetching phase data: $e');
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
