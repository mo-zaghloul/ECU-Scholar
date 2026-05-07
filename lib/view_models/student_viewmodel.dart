import 'package:ecu_scholar/models/student_model.dart';
import 'package:ecu_scholar/services/auth_service/auth_service.dart';
import 'package:flutter/material.dart';
import '../services/remote_data_service/remote_data_service.dart';

enum StudentLoadingState { initial, loading, loaded, error }

class StudentViewModel extends ChangeNotifier {
  Student _studentData = Student.empty();
  StudentLoadingState _loadingState = StudentLoadingState.initial;
  String? _errorMessage;

  /// Set student data directly (used after auth/init)
  void setStudent(Student student) {
    _studentData = student;
    _loadingState = StudentLoadingState.loaded;
    _errorMessage = null;
    notifyListeners();
    debugPrint('StudentViewModel: Student data set - ${student.name}');
  }

  /// Load cached student data from AuthService (called on app startup)
  /// This restores student info from SharedPreferences on app restart
  void loadCachedStudentData() {
    final authService = AuthService.instance;
    final studentId = authService.studentId;
    final studentName = authService.studentName;
    final studentFaculty = authService.studentFaculty;

    // Only load if we have at least an ID and name
    if (studentId != null && studentId.isNotEmpty && 
        studentName != null && studentName.isNotEmpty) {
      _studentData = Student(
        id: studentId,
        name: studentName,
        faculty: studentFaculty ?? '',
        major: '',
        year: '',
        totalPassedCH: 0,
        courseRegStatus: '',
      );
      _loadingState = StudentLoadingState.loaded;
      debugPrint('StudentViewModel: Cached student data loaded - $studentName');
      notifyListeners();
    }
  }

  StudentLoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == StudentLoadingState.loading;

  Future<void> fetchStudentData() async {
    _loadingState = StudentLoadingState.loading;
    _errorMessage = null;
    notifyListeners();
    debugPrint('StudentViewModel: Fetching student data...');

    try {
      // Create fresh API service instance to ensure latest auth headers are used
      final apiService = BackendApiService();
      _studentData = await apiService.fetchStudentData();
      _loadingState = StudentLoadingState.loaded;
      debugPrint('StudentViewModel: Student data loaded - ${_studentData.name}');
      notifyListeners();
    } catch (e) {
      debugPrint('StudentViewModel: Error fetching student data: $e');
      _errorMessage = e.toString();
      _loadingState = StudentLoadingState.error;
      notifyListeners();
    }
  }

  Student get studentData => _studentData;
}
