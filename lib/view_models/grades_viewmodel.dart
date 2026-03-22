import 'package:flutter/material.dart';
import '../models/grade_model.dart';
import '../services/remote_data_service/remote_data_service.dart';

enum GradesLoadingState { initial, loading, loaded, error }

class GradesViewModel extends ChangeNotifier {
  GradesLoadingState _gradesState = GradesLoadingState.initial;
  GradesLoadingState _gpaState = GradesLoadingState.initial;

  GpaSummary _gpaSummary = GpaSummary.empty();
  List<AcademicYearSemesters> _academicYears = [];
  Map<String, List<Grade>> _gradesBySemester = {};
  
  String? _selectedAcademicYear;
  String? _errorMessage;

  // Getters
  GradesLoadingState get gradesState => _gradesState;
  GradesLoadingState get gpaState => _gpaState;
  GpaSummary get gpaSummary => _gpaSummary;
  List<AcademicYearSemesters> get academicYears => _academicYears;
  String? get selectedAcademicYear => _selectedAcademicYear;
  String? get errorMessage => _errorMessage;
  bool get isLoading => 
      _gradesState == GradesLoadingState.loading || 
      _gpaState == GradesLoadingState.loading;

  /// Get grades grouped by semester for selected academic year
  Map<String, List<Grade>> get gradesBySemester => _gradesBySemester;

  /// Get semester order (Fall comes before Spring in display)
  List<String> get orderedSemesters {
    final semesters = _gradesBySemester.keys.toList();
    // Sort: Fall before Spring
    semesters.sort((a, b) {
      if (a == 'Fall' && b == 'Spring') return -1;
      if (a == 'Spring' && b == 'Fall') return 1;
      return a.compareTo(b);
    });
    return semesters;
  }

  /// Initialize and load all grades data
  Future<void> loadGradesData() async {
    await Future.wait([
      _loadGpaSummary(),
      _loadSemesters(),
    ]);
  }

  Future<void> _loadGpaSummary() async {
    _gpaState = GradesLoadingState.loading;
    notifyListeners();

    try {
      final apiService = BackendApiService();
      _gpaSummary = await apiService.fetchGpaSummary();
      _gpaState = GradesLoadingState.loaded;
    } catch (e) {
      debugPrint('Error loading GPA: $e');
      _gpaState = GradesLoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> _loadSemesters() async {
    try {
      final apiService = BackendApiService();
      _academicYears = await apiService.fetchGradeSemesters();
      
      // Auto-select the most recent academic year
      if (_academicYears.isNotEmpty && _selectedAcademicYear == null) {
        await selectAcademicYear(_academicYears.first.academicYear);
      }
    } catch (e) {
      debugPrint('Error loading semesters: $e');
      _errorMessage = e.toString();
    }
  }

  /// Select an academic year and load its grades
  Future<void> selectAcademicYear(String academicYear) async {
    if (_selectedAcademicYear == academicYear && _gradesBySemester.isNotEmpty) {
      return; // Already loaded
    }

    _selectedAcademicYear = academicYear;
    _gradesState = GradesLoadingState.loading;
    _gradesBySemester = {};
    notifyListeners();

    try {
      final apiService = BackendApiService();
      final grades = await apiService.fetchGrades(academicYear: academicYear);
      
      // Group grades by semester
      for (final grade in grades) {
        _gradesBySemester.putIfAbsent(grade.semester, () => []);
        _gradesBySemester[grade.semester]!.add(grade);
      }

      _gradesState = GradesLoadingState.loaded;
    } catch (e) {
      debugPrint('Error loading grades for $academicYear: $e');
      _gradesState = GradesLoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Calculate total credit hours for a semester
  /// NOTE: Currently commented out - using backend credits from SemesterGpa instead
  /// Kept for potential future use if local calculation is needed
  /*
  double getTotalHoursForSemester(String semester) {
    final grades = _gradesBySemester[semester] ?? [];
    return grades.fold(0.0, (sum, g) => sum + g.creditHours);
  }
  */

  /// Get GPA for a specific semester (returns GPA value only)
  double? getGpaForSemester(String academicYear, String semester) {
    final semesterGpa = _gpaSummary.bySemester.firstWhere(
      (s) => s.academicYear == academicYear && s.semester == semester,
      orElse: () => SemesterGpa(
        academicYear: '',
        semester: '',
        gpa: 0,
        credits: 0,
      ),
    );
    return semesterGpa.gpa > 0 ? semesterGpa.gpa : null;
  }

  /// Get full semester GPA data (returns SemesterGpa object with GPA and credits)
  SemesterGpa? getSemesterGpaData(String academicYear, String semester) {
    try {
      return _gpaSummary.bySemester.firstWhere(
        (s) => s.academicYear == academicYear && s.semester == semester,
      );
    } catch (_) {
      return null; // Return null if not found instead of throwing
    }
  }
}
