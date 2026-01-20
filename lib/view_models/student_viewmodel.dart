import 'package:ecu_scholar/models/student_model.dart';
import 'package:flutter/material.dart';
import '../services/remote_data_service/remote_data_service.dart';

enum StudentLoadingState { initial, loading, loaded, error }

class StudentViewModel extends ChangeNotifier {
  Student _studentData = Student(
    name: 'N/A',
    faculty: 'N/A',
    gpa: 'N/A',
    // id: 'N/A',
    // degree: 'N/A',
    // major: 'N/A',
    // level: 'N/A',
    // totalPassedHours: 'N/A',
  );
  StudentLoadingState _loadingState = StudentLoadingState.initial;
  String? _errorMessage;
  final BackendApiService _apiService = BackendApiService();

  StudentLoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == StudentLoadingState.loading;

  Future<void> fetchStudentData() async {
    _loadingState = StudentLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _studentData = await _apiService.fetchStudentData();
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
