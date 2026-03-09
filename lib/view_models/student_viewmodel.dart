import 'package:ecu_scholar/models/student_model.dart';
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

  StudentLoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == StudentLoadingState.loading;

  Future<void> fetchStudentData() async {
    _loadingState = StudentLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create fresh API service instance to ensure latest auth headers are used
      final apiService = BackendApiService();
      _studentData = await apiService.fetchStudentData();
      _loadingState = StudentLoadingState.loaded;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching student data: $e');
      _errorMessage = e.toString();
      _loadingState = StudentLoadingState.error;
      notifyListeners();
    }
  }

  Student get studentData => _studentData;
}
