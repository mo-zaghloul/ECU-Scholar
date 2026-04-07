import 'package:dio/dio.dart';
import 'package:ecu_scholar/models/grade_model.dart';
import 'package:ecu_scholar/models/schedule_model.dart';
import 'package:ecu_scholar/models/student_model.dart';
import 'package:flutter/material.dart';

import '../../constants/secrets.dart';
import '../auth_service/auth_service.dart';

/// Response from the auth/init endpoint
class AuthInitResponse {
  final Student student;
  final List<String> scraped;
  final String message;

  AuthInitResponse({
    required this.student,
    required this.scraped,
    required this.message,
  });

  factory AuthInitResponse.fromJson(Map<String, dynamic> json) {
    // Handle student as either an object or an array
    dynamic studentData = json['student'] ?? {};
    if (studentData is List && studentData.isNotEmpty) {
      studentData = studentData.first; // Extract first student if it's an array
    }
    
    return AuthInitResponse(
      student: Student.fromJson(studentData is Map<String, dynamic> 
          ? studentData 
          : (studentData as Map).cast<String, dynamic>()),
      scraped: (json['scraped'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      message: json['message']?.toString() ?? '',
    );
  }
}

class BackendApiService {
  late final Dio _dio;
  final AuthService _authService = AuthService.instance;

  BackendApiService() {
    final token = _authService.sessionToken ?? '';
    final studentId = _authService.studentId ?? '';
    debugPrint('Base URL: $baseUrl');
    debugPrint('Sess: $token');

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'accept': 'application/json',
        'X-Session-Token': token,
        'X-Student-Id': studentId,
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  /// Update the session token in the headers (useful after re-authentication)
  void updateSessionToken() {
    final token = _authService.sessionToken ?? '';
    final studentId = _authService.studentId ?? '';
    _dio.options.headers['X-Session-Token'] = token;
    _dio.options.headers['X-Student-Id'] = studentId;
    debugPrint('Session token updated in API service');
  }

  /// Initialize auth with session token - backend scrapes profile, schedule, grades
  /// This is called after intercepting ASP.NET_SessionId cookie
  Future<AuthInitResponse> authInit(String sessionToken) async {
    try {
      // Use a separate Dio instance for auth init since we don't have student ID yet
      final authDio = Dio(BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'accept': 'application/json',
          'X-Session-Token': sessionToken,
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120), // Longer timeout for scraping
      ));

      final response = await authDio.post('/auth/init');

      debugPrint('Auth init response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = AuthInitResponse.fromJson(response.data);
        debugPrint('Success: Auth initialized, student ID: ${result.student.id}');
        return result;
      } else {
        throw Exception('Failed to initialize auth. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Auth init DioException: ${e.message}');
      if (e.response != null) {
        final errorMsg = e.response?.data['detail'] ?? e.response?.data['message'] ?? e.message;
        throw Exception(errorMsg);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Failed to initialize auth: $e');
      rethrow;
    }
  }
  Future<AuthInitResponse> authLogin(String sessionToken) async {
    try{
      final authDio = Dio(BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'accept': 'application/json',
          'X-Session-Token': sessionToken,
        },
      ));

    final response = await authDio.post('/auth/login');
    debugPrint('Auth login response: ${response.data}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = AuthInitResponse.fromJson(response.data);
      debugPrint('Success: Auth login complete, student ID: ${result.student.id}');
      return result;
    } else {
      throw Exception('Failed to login. Status: ${response.statusCode}');
    }
    } on DioException catch (e) {
      debugPrint('Auth login DioException: ${e.message}');
      if (e.response != null) {
        final errorMsg = e.response?.data['detail'] ?? e.response?.data['message'] ?? e.message;
        throw Exception(errorMsg);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Failed to login: $e');
      rethrow;
    }
  }
  /// Trigger a re-scrape of data from SIS
  Future<void> refreshScrape() async {
    try {
      final response = await _dio.post('/scrape/refresh');

      if (response.statusCode == 200) {
        debugPrint('Success: Data refresh triggered');
      } else {
        throw Exception('Failed to refresh data. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to refresh scrape: $e');
      rethrow;
    }
  }

  /// Fetch week schedule organized by day
  Future<Map<int, List<Schedule>>> fetchWeekSchedule() async {
    try {
      final response = await _dio.get('/schedule/week');
      debugPrint('Response: ${response.data}');
      
      if (response.statusCode == 200) {
        final Map<int, List<Schedule>> weekSchedule = {};
        final days = response.data['days'] as List<dynamic>? ?? [];
        
        for (final dayData in days) {
          // Handle day as either int or string
          final dayValue = dayData['day'];
          final dayNum = dayValue is int ? dayValue : int.tryParse(dayValue.toString()) ?? 0;
          
          if (dayNum == 0) continue; // Skip invalid days
          
          final classes = (dayData['classes'] as List<dynamic>?) ?? [];
          
          weekSchedule[dayNum] = classes
              .map((item) => Schedule.fromJson({
                    ...item as Map<String, dynamic>,
                    'day_of_week': dayNum,
                  }))
              .toList();
        }
        
        debugPrint('Success: Week schedule loaded (${weekSchedule.length} days)');
        return weekSchedule;
      } else {
        throw Exception('Failed to load schedule. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to fetch week schedule: $e');
      throw Exception('Failed to fetch week schedule: $e');
    }
  }

  /// Fetch all schedules (flat list)
  Future<List<Schedule>> fetchSchedules() async {
    try {
      final response = await _dio.get('/schedule');
      debugPrint('Response: ${response.data}');
      if (response.statusCode == 200) {
        final List<dynamic> scheduleList = response.data['schedule'] ?? [];
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
      final response = await _dio.get('/student/profile');

      if (response.statusCode == 200) {
        final studentData = response.data['student'] as Map<String, dynamic>;
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

  /// Fetch GPA summary including cumulative GPA and semester GPAs
  Future<GpaSummary> fetchGpaSummary() async {
    try {
      final response = await _dio.get('/grades/gpa');

      if (response.statusCode == 200) {
        debugPrint('Success: GPA summary loaded');
        return GpaSummary.fromJson(response.data);
      } else {
        throw Exception('Failed to load GPA. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to fetch GPA summary: $e');
      throw Exception('Failed to fetch GPA summary: $e');
    }
  }

  /// Fetch list of semesters with grades
  Future<List<AcademicYearSemesters>> fetchGradeSemesters() async {
    try {
      final response = await _dio.get('/grades/semesters');

      if (response.statusCode == 200) {
        final semesters = response.data['semesters'] as List<dynamic>? ?? [];
        debugPrint('Success: ${semesters.length} semester entries loaded');
        return parseSemestersList(semesters);
      } else {
        throw Exception('Failed to load semesters. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to fetch semesters: $e');
      throw Exception('Failed to fetch semesters: $e');
    }
  }

  /// Fetch grades for a specific academic year (and optionally semester)
  Future<List<Grade>> fetchGrades({
    String? academicYear,
    String? semester,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (academicYear != null) queryParams['academic_year'] = academicYear;
      if (semester != null) queryParams['semester'] = semester;

      final response = await _dio.get(
        '/grades',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final gradesList = response.data['grades'] as List<dynamic>? ?? [];
        final grades = gradesList.map((e) => Grade.fromJson(e)).toList();
        debugPrint('Success: ${grades.length} grades loaded');
        return grades;
      } else {
        throw Exception('Failed to load grades. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to fetch grades: $e');
      throw Exception('Failed to fetch grades: $e');
    }
  }
}
