import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for managing onboarding state.
/// Tracks whether the user has completed the onboarding flow.
class OnboardingService {
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static OnboardingService? _instance;

  SharedPreferences? _prefs;
  bool _isOnboardingComplete = false;

  OnboardingService._internal();

  /// Singleton instance of OnboardingService
  static OnboardingService get instance {
    _instance ??= OnboardingService._internal();
    return _instance!;
  }

  /// Initialize the onboarding service and load saved state
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isOnboardingComplete = _prefs?.getBool(_onboardingCompleteKey) ?? false;
    debugPrint('OnboardingService initialized. Complete: $_isOnboardingComplete');
  }

  /// Check if onboarding has been completed
  bool get isOnboardingComplete => _isOnboardingComplete;

  /// Mark onboarding as complete
  Future<bool> completeOnboarding() async {
    try {
      if (_prefs == null) {
        await initialize();
      }
      await _prefs?.setBool(_onboardingCompleteKey, true);
      _isOnboardingComplete = true;
      debugPrint('Onboarding marked as complete');
      return true;
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      return false;
    }
  }

  /// Reset onboarding state (useful for testing)
  Future<bool> resetOnboarding() async {
    try {
      if (_prefs == null) {
        await initialize();
      }
      await _prefs?.remove(_onboardingCompleteKey);
      _isOnboardingComplete = false;
      debugPrint('Onboarding reset');
      return true;
    } catch (e) {
      debugPrint('Error resetting onboarding: $e');
      return false;
    }
  }
}
