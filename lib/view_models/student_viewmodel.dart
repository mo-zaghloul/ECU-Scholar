import 'package:ecu_scholar/models/student_model.dart';
import 'package:flutter/material.dart';
import '../services/remote_data_service/remote_data_service.dart';

class StudentViewModel extends ChangeNotifier {
  Student _studentData = Student(
    name: 'N/A',
    id: 'N/A',
    degree: 'N/A',
    faculty: 'N/A',
    major: 'N/A',
    cgpa: 'N/A',
    level: 'N/A',
    totalPassedHours: 'N/A',
  );

  Future<void> fetchStudentData() async {
    _studentData = await LMSUniversityApi().fetchStudentData();
    notifyListeners();
  }

  Student get studentData => _studentData;
}
