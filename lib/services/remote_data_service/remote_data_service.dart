import 'package:dio/dio.dart';
import 'package:ecu_scholar/models/schedule_model.dart';
import 'package:ecu_scholar/models/student_model.dart';
import 'package:flutter/material.dart';

import '../../constants/secrets.dart';

class BackendApiService {
  late final Dio _dio;

  BackendApiService() {
    debugPrint('Base URL: $baseUrl');
    debugPrint('Sess: $sessionToken');

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'accept': 'application/json',
        'x-session-token': sessionToken,
      },
    ));
  }

  Future<List<Schedule>> fetchSchedules() async {
    try {
      final response = await _dio.get('/scraping/schedule');

      if (response.statusCode == 200) {
        final List<dynamic> scheduleList = response.data['schedule'];
        final schedules = scheduleList
            .map((item) => Schedule.fromJson(item as Map<String, dynamic>))
            .toList();

        debugPrint('Success: Schedules loaded successfully');
        return schedules;
      } else {
        debugPrint('Failed to load schedules. Status code: ${response.statusCode}');
        throw Exception('Failed to load schedules. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to fetch schedules: $e');
      throw Exception('Failed to fetch schedules: $e');
    }
  }

  Future<Student> fetchStudentData() async {
    try {
      final response = await _dio.get('/scraping/student');

      if (response.statusCode == 200) {
        final studentData = response.data as Map<String, dynamic>;
        debugPrint('Success: Student data loaded successfully');
        return Student.fromJson(studentData);
      } else {
        debugPrint('Failed to load student data. Status code: ${response.statusCode}');
        throw Exception('Failed to load student data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to fetch student data: $e');
      throw Exception('Failed to fetch student data: $e');
    }
  }
}
