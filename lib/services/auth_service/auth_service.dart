import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for managing authentication state and session token storage.
/// Uses SharedPreferences for persistent local storage of auth credentials and user info.
class AuthService {
  static const String _sessionTokenKey = 'asp_net_session_id';
  static const String _studentIdKey = 'student_id';
  static const String _studentNameKey = 'student_name';
  static const String _studentFacultyKey = 'student_faculty';
  static AuthService? _instance;
  
  SharedPreferences? _prefs;
  String? _cachedToken;
  String? _cachedStudentId;
  String? _cachedStudentName;
  String? _cachedStudentFaculty;

  AuthService._internal();

  /// Singleton instance of AuthService
  static AuthService get instance {
    _instance ??= AuthService._internal();
    return _instance!;
  }

  /// Initialize the auth service and load any cached credentials
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _cachedToken = _prefs?.getString(_sessionTokenKey);
    _cachedStudentId = _prefs?.getString(_studentIdKey);
    _cachedStudentName = _prefs?.getString(_studentNameKey);
    _cachedStudentFaculty = _prefs?.getString(_studentFacultyKey);
    debugPrint('AuthService initialized. Token exists: ${_cachedToken != null}');
  }

  /// Get the current session token
  String? get sessionToken => _cachedToken;

  /// Get the current student ID
  String? get studentId => _cachedStudentId;

  /// Get the cached student name
  String? get studentName => _cachedStudentName;

  /// Get the cached student faculty
  String? get studentFaculty => _cachedStudentFaculty;

  /// Check if user is authenticated (has a valid session token)
  bool get isAuthenticated => _cachedToken != null && _cachedToken!.isNotEmpty;

  /// Save a new session token
  Future<bool> saveSessionToken(String token) async {
    try {
      if (_prefs == null) {
        await initialize();
      }
      await _prefs?.setString(_sessionTokenKey, token);
      _cachedToken = token;
      debugPrint('Session token saved successfully');
      return true;
    } catch (e) {
      debugPrint('Error saving session token: $e');
      return false;
    }
  }

  /// Save the student ID
  Future<bool> saveStudentId(String studentId) async {
    try {
      if (_prefs == null) {
        await initialize();
      }
      await _prefs?.setString(_studentIdKey, studentId);
      _cachedStudentId = studentId;
      debugPrint('Student ID saved successfully');
      return true;
    } catch (e) {
      debugPrint('Error saving student ID: $e');
      return false;
    }
  }

  /// Save the student name (cached for quick access in UI)
  Future<bool> saveStudentName(String studentName) async {
    try {
      if (_prefs == null) {
        await initialize();
      }
      await _prefs?.setString(_studentNameKey, studentName);
      _cachedStudentName = studentName;
      debugPrint('Student name saved successfully');
      return true;
    } catch (e) {
      debugPrint('Error saving student name: $e');
      return false;
    }
  }

  /// Save the student faculty (cached for quick access in UI)
  Future<bool> saveStudentFaculty(String studentFaculty) async {
    try {
      if (_prefs == null) {
        await initialize();
      }
      await _prefs?.setString(_studentFacultyKey, studentFaculty);
      _cachedStudentFaculty = studentFaculty;
      debugPrint('Student faculty saved successfully');
      return true;
    } catch (e) {
      debugPrint('Error saving student faculty: $e');
      return false;
    }
  }

  /// Clear all authentication data (logout)
  Future<bool> clearSessionToken() async {
    try {
      if (_prefs == null) {
        await initialize();
      }
      await _prefs?.remove(_sessionTokenKey);
      await _prefs?.remove(_studentIdKey);
      await _prefs?.remove(_studentNameKey);
      await _prefs?.remove(_studentFacultyKey);
      _cachedToken = null;
      _cachedStudentId = null;
      _cachedStudentName = null;
      _cachedStudentFaculty = null;
      debugPrint('Session token cleared successfully');
      return true;
    } catch (e) {
      debugPrint('Error clearing session token: $e');
      return false;
    }
  }
}
