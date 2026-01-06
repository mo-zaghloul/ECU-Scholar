import 'package:ecu_scholar/models/student_model.dart';
import 'package:flutter/material.dart';
import '../services/remote_data_service/remote_data_service.dart';

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
  final BackendApiService _apiService = BackendApiService();

  Future<void> fetchStudentData() async {
    try {
      _studentData = await _apiService.fetchStudentData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching student data: $e');
      notifyListeners();
    }
  }

  Student get studentData => _studentData;
}
