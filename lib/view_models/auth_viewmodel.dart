import 'package:flutter/foundation.dart';
import '../services/auth_service/auth_service.dart';

/// Enum representing the different states of authentication
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// ViewModel for managing authentication state and operations.
/// Follows MVVM pattern and notifies listeners of state changes.
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;

  AuthState _state = AuthState.initial;
  String? _errorMessage;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get sessionToken => _authService.sessionToken;
  bool get isAuthenticated => _authService.isAuthenticated;

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

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
}
