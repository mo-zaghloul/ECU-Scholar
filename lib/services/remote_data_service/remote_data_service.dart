import 'package:dio/dio.dart';
import 'package:ecu_scholar/models/grade_model.dart';
import 'package:ecu_scholar/models/schedule_model.dart';
import 'package:ecu_scholar/models/student_model.dart';
import 'package:flutter/material.dart';

import '../../constants/secrets.dart';
import '../auth_service/auth_service.dart';
import '../exceptions/api_exception.dart';
import '../exceptions/dio_error_interceptor.dart';

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

    // Add error interceptor
    _dio.interceptors.add(DioErrorInterceptor());
  }

  /// Update the session token in the headers (useful after re-authentication)
  void updateSessionToken() {
    final token = _authService.sessionToken ?? '';
    final studentId = _authService.studentId ?? '';
    _dio.options.headers['X-Session-Token'] = token;
    _dio.options.headers['X-Student-Id'] = studentId;
    debugPrint('Session token updated in API service');
  }

  /// Helper method to handle DioException and convert to ApiException
  ApiException _handleDioError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    if (error is DioException) {
      return DioErrorInterceptor.convertDioException(error);
    }
    return ApiException(
      message: error.toString(),
      code: 'UNKNOWN_ERROR',
    );
  }

  /// Initialize auth with session token - backend scrapes profile, schedule, grades
  /// This is called after intercepting ASP.NET_SessionId cookie
  /// Includes FCM token for push notification registration
  Future<AuthInitResponse> authInit(String sessionToken, {String? fcmToken}) async {
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

      // Add error interceptor
      authDio.interceptors.add(DioErrorInterceptor());

      // Prepare request body with FCM token
      final requestBody = <String, dynamic>{};
      if (fcmToken != null && fcmToken.isNotEmpty) {
        requestBody['fcm_token'] = fcmToken;
        debugPrint('Including FCM token in auth/init request');
      }

      final response = requestBody.isEmpty
          ? await authDio.post('/auth/init')
          : await authDio.post('/auth/init', data: requestBody);

      debugPrint('Auth init response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = AuthInitResponse.fromJson(response.data);
        debugPrint('✅ Auth initialized successfully. Student ID: ${result.student.id}');
        return result;
      } else {
        throw ApiException(
          message: 'Failed to initialize auth. Status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // Extract ApiException if wrapped inside DioException by interceptor
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      final apiException = DioErrorInterceptor.convertDioException(e);
      throw apiException;
    } catch (e) {
      debugPrint('❌ Failed to initialize auth: $e');
      rethrow;
    }
  }

  /// Dev mode login with session token - uses /auth/login endpoint
  /// Faster than authInit, doesn't trigger scraping
  Future<AuthInitResponse> authLogin(String sessionToken) async {
    try {
      // Use a separate Dio instance for auth login
      final authDio = Dio(BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'accept': 'application/json',
          'X-Session-Token': sessionToken,
        },
      ));

      // Add error interceptor
      authDio.interceptors.add(DioErrorInterceptor());

      final response = await authDio.post('/auth/login');
      debugPrint('Auth login response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = AuthInitResponse.fromJson(response.data);
        debugPrint('✅ Auth login complete, student ID: ${result.student.id}');
        return result;
      } else {
        throw ApiException(
          message: 'Failed to login. Status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // Extract ApiException if wrapped inside DioException by interceptor
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      final apiException = DioErrorInterceptor.convertDioException(e);
      throw apiException;
    } catch (e) {
      debugPrint('❌ Failed to login: $e');
      rethrow;
    }
  }

  /// Trigger a re-scrape of data from SIS
  Future<void> refreshScrape() async {
    try {
      final response = await _dio.post('/scrape/refresh');

      if (response.statusCode == 200) {
        debugPrint('✅ Data refresh triggered');
      } else {
        throw ApiException(
          message: 'Failed to refresh data. Status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to refresh scrape: $e');
      rethrow;
    }
  }

  /// Fetch week schedule organized by day
  Future<Map<int, List<Schedule>>> fetchWeekSchedule() async {
    try {
      final response = await _dio.get('/schedule/week');
      
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
        
        debugPrint('✅ Week schedule loaded (${weekSchedule.length} days)');
        return weekSchedule;
      } else {
        throw ApiException(
          message: 'Failed to load schedule.',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // Extract ApiException if wrapped inside DioException by interceptor
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      rethrow;
    } catch (e) {
      debugPrint('❌ Failed to fetch week schedule: $e');
      throw _handleDioError(e);
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

        debugPrint('✅ Schedules loaded successfully');
        return schedules;
      } else {
        debugPrint('❌ Failed to load schedules. Status code: ${response.statusCode}');
        throw ApiException(
          message: 'Failed to load schedules.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch schedules: $e');
      rethrow;
    }
  }

  /// Fetch student profile data
  Future<Student> fetchStudentData() async {
    try {
      final response = await _dio.get('/student/profile');

      if (response.statusCode == 200) {
        final studentData = response.data['student'] as Map<String, dynamic>;
        debugPrint('✅ Student data loaded successfully');
        return Student.fromJson(studentData);
      } else {
        debugPrint('❌ Failed to load student data. Status code: ${response.statusCode}');
        throw ApiException(
          message: 'Failed to load student data.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch student data: $e');
      rethrow;
    }
  }

  /// Fetch GPA summary including cumulative GPA and semester GPAs
  Future<GpaSummary> fetchGpaSummary() async {
    try {
      final response = await _dio.get('/grades/gpa');

      if (response.statusCode == 200) {
        debugPrint('✅ GPA summary loaded');
        return GpaSummary.fromJson(response.data);
      } else {
        throw ApiException(
          message: 'Failed to load GPA.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch GPA summary: $e');
      rethrow;
    }
  }

  /// Fetch list of semesters with grades
  Future<List<AcademicYearSemesters>> fetchGradeSemesters() async {
    try {
      final response = await _dio.get('/grades/semesters');

      if (response.statusCode == 200) {
        final semesters = response.data['semesters'] as List<dynamic>? ?? [];
        debugPrint('✅ ${semesters.length} semester entries loaded');
        return parseSemestersList(semesters);
      } else {
        throw ApiException(
          message: 'Failed to load semesters.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch semesters: $e');
      rethrow;
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
        debugPrint('✅ ${grades.length} grades loaded');
        return grades;
      } else {
        throw ApiException(
          message: 'Failed to load grades.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch grades: $e');
      rethrow;
    }
  }

  /// Logout user and clear FCM token from backend
  /// Unregisters the device from receiving push notifications
  Future<void> authLogout() async {
    try {
      final sessionToken = _authService.sessionToken;
      final studentId = _authService.studentId;

      if (sessionToken == null || sessionToken.isEmpty) {
        debugPrint('⚠️ No session token available for logout');
        return;
      }

      final response = await _dio.post(
        '/auth/logout',
        options: Options(
          headers: {
            'X-Session-Token': sessionToken,
            'X-Student-Id': studentId ?? '',
          },
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Logged out successfully');
      } else {
        throw ApiException(
          message: 'Failed to logout.',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // Extract ApiException if wrapped inside DioException by interceptor
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      final apiException = DioErrorInterceptor.convertDioException(e);
      throw apiException;
    } catch (e) {
      debugPrint('❌ Failed to logout: $e');
      rethrow;
    }
  }
}
