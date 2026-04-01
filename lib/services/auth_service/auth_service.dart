import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for managing authentication state and session token storage.
/// Uses SharedPreferences for persistent local storage of the session token.
class AuthService {
  static const String _sessionTokenKey = 'asp_net_session_id';
  static const String _studentIdKey = 'student_id';
  static AuthService? _instance;
  
  SharedPreferences? _prefs;
  String? _cachedToken;
  String? _cachedStudentId;

  AuthService._internal();

  /// Singleton instance of AuthService
  static AuthService get instance {
    _instance ??= AuthService._internal();
    return _instance!;
  }

  /// Initialize the auth service and load any cached token
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _cachedToken = _prefs?.getString(_sessionTokenKey);
    _cachedStudentId = _prefs?.getString(_studentIdKey);
    debugPrint('AuthService initialized. Token exists: ${_cachedToken != null}');
  }

  /// Get the current session token
  String? get sessionToken => _cachedToken;

  /// Get the current student ID
  String? get studentId => _cachedStudentId;

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

  /// Clear the session token (logout)
  Future<bool> clearSessionToken() async {
    try {
      if (_prefs == null) {
        await initialize();
      }
      await _prefs?.remove(_sessionTokenKey);
      await _prefs?.remove(_studentIdKey);
      _cachedToken = null;
      _cachedStudentId = null;
      debugPrint('Session token cleared successfully');
      return true;
    } catch (e) {
      debugPrint('Error clearing session token: $e');
      return false;
    }
  }
}
