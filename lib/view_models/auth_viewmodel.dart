import 'package:flutter/foundation.dart';
import '../models/student_model.dart';
import '../services/auth_service/auth_service.dart';
import '../services/remote_data_service/remote_data_service.dart';

/// Enum representing the different states of authentication
enum AuthState {
  initial,
  loading,
  processing, // New state for backend processing
  authenticated,
  unauthenticated,
  error,
}

/// Result of auth initialization containing student data
class AuthInitResult {
  final bool success;
  final Student? student;
  final String? errorMessage;

  AuthInitResult({required this.success, this.student, this.errorMessage});
}

/// ViewModel for managing authentication state and operations.
/// Follows MVVM pattern and notifies listeners of state changes.
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  Student? _cachedStudent;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get sessionToken => _authService.sessionToken;
  bool get isAuthenticated => _authService.isAuthenticated;
  Student? get cachedStudent => _cachedStudent;

  /// Initialize the auth view model and check for existing session
  Future<void> initialize() async {
    _setState(AuthState.loading);
    
    try {
      await _authService.initialize();
      
      if (_authService.isAuthenticated) {
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize authentication: $e';
      _setState(AuthState.error);
      debugPrint(_errorMessage);
    }
  }

  /// Save the session token after successful authentication
  Future<bool> saveSessionToken(String token) async {
    _setState(AuthState.loading);
    
    try {
      final success = await _authService.saveSessionToken(token);
      
      if (success) {
        _setState(AuthState.authenticated);
        return true;
      } else {
        _errorMessage = 'Failed to save session token';
        _setState(AuthState.error);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error saving session token: $e';
      _setState(AuthState.error);
      debugPrint(_errorMessage);
      return false;
    }
  }

  /// Clear the session token (logout)
  Future<void> logout() async {
    _setState(AuthState.loading);
    
    try {
      await _authService.clearSessionToken();
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _errorMessage = 'Error during logout: $e';
      _setState(AuthState.error);
      debugPrint(_errorMessage);
    }
  }

  /// Initialize authentication with a session token from SIS cookie.
  /// Calls backend /auth/init to scrape and store student data.
  /// Returns AuthInitResult with student data on success.
  Future<AuthInitResult> initializeWithToken(String sessionToken) async {
    _setState(AuthState.processing);
    _errorMessage = null;
    _cachedStudent = null;

    try {
      // First, save the session token locally
      final tokenSaved = await _authService.saveSessionToken(sessionToken);
      if (!tokenSaved) {
        _errorMessage = 'Failed to save session token locally';
        _setState(AuthState.error);
        return AuthInitResult(success: false, errorMessage: _errorMessage);
      }

      // Call backend to initialize auth and scrape data
      final apiService = BackendApiService();
      final response = await apiService.authInit(sessionToken);

      // Save the student ID, name, and faculty from the response
      final student = response.student;
      if (student.id.isNotEmpty) {
        await _authService.saveStudentId(student.id);
        await _authService.saveStudentName(student.name);
        await _authService.saveStudentFaculty(student.faculty);
        _cachedStudent = student;
        debugPrint('Auth init complete: Student ${student.name} (ID: ${student.id})');
      } else {
        _errorMessage = 'No student ID returned from server';
        _setState(AuthState.error);
        return AuthInitResult(success: false, errorMessage: _errorMessage);
      }

      _setState(AuthState.authenticated);
      return AuthInitResult(success: true, student: student);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setState(AuthState.error);
      debugPrint('Auth init error: $_errorMessage');
      return AuthInitResult(success: false, errorMessage: _errorMessage);
    }
  }

  /// Dev mode login with session token - uses /auth/login endpoint
  /// Faster than authInit, doesn't trigger scraping
  /// Returns AuthInitResult with student data on success.
  Future<AuthInitResult> loginWithToken(String sessionToken) async {
    _setState(AuthState.processing);
    _errorMessage = null;
    _cachedStudent = null;

    try {
      // First, save the session token locally
      final tokenSaved = await _authService.saveSessionToken(sessionToken);
      if (!tokenSaved) {
        _errorMessage = 'Failed to save session token locally';
        _setState(AuthState.error);
        return AuthInitResult(success: false, errorMessage: _errorMessage);
      }

      // Call backend to login with session token
      final apiService = BackendApiService();
      final response = await apiService.authLogin(sessionToken);

      // Save the student ID, name, and faculty from the response
      final student = response.student;
      if (student.id.isNotEmpty) {
        await _authService.saveStudentId(student.id);
        await _authService.saveStudentName(student.name);
        await _authService.saveStudentFaculty(student.faculty);
        _cachedStudent = student;
        debugPrint('Dev login complete: Student ${student.name} (ID: ${student.id})');
      } else {
        _errorMessage = 'No student ID returned from server';
        _setState(AuthState.error);
        return AuthInitResult(success: false, errorMessage: _errorMessage);
      }

      _setState(AuthState.authenticated);
      return AuthInitResult(success: true, student: student);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setState(AuthState.error);
      debugPrint('Dev login error: $_errorMessage');
      return AuthInitResult(success: false, errorMessage: _errorMessage);
    }
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
}
