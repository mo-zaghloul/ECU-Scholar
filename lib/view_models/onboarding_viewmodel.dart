import 'package:flutter/foundation.dart';
import '../services/onboarding_service/onboarding_service.dart';

/// Model representing a single onboarding page
class OnboardingPageData {
  final String svgAsset;
  final String title;
  final String subtitle;

  const OnboardingPageData({
    required this.svgAsset,
    required this.title,
    required this.subtitle,
  });
}

/// ViewModel for managing onboarding state and navigation.
class OnboardingViewModel extends ChangeNotifier {
  final OnboardingService _onboardingService = OnboardingService.instance;

  int _currentPage = 0;
  bool _isCompleting = false;

  int get currentPage => _currentPage;
  bool get isCompleting => _isCompleting;
  bool get isLastPage => _currentPage == pages.length - 1;
  bool get isFirstPage => _currentPage == 0;

  /// Onboarding pages data
  final List<OnboardingPageData> pages = const [
    OnboardingPageData(
      svgAsset: 'assets/onboarding/Smart People.svg',
      title: 'Welcome to ECU Scholar',
      subtitle: 'Your all-in-one companion for navigating university life. Connect, learn, and succeed together.',
    ),
    OnboardingPageData(
      svgAsset: 'assets/onboarding/Student Studying.svg',
      title: 'Track Your Progress',
      subtitle: 'Access your grades, GPA, and academic records anytime. Stay on top of your academic journey.',
    ),
    OnboardingPageData(
      svgAsset: 'assets/onboarding/Manager Desk.svg',
      title: 'Manage Your Schedule',
      subtitle: 'View your class schedule, keep track of tasks, and never miss an important deadline.',
    ),
  ];

  /// Update the current page index
  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  /// Go to the next page
  void nextPage() {
    if (_currentPage < pages.length - 1) {
      _currentPage++;
      notifyListeners();
    }
  }

  /// Go to the previous page
  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  /// Complete the onboarding and save state
  Future<bool> completeOnboarding() async {
    _isCompleting = true;
    notifyListeners();

    try {
      final success = await _onboardingService.completeOnboarding();
      _isCompleting = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      _isCompleting = false;
      notifyListeners();
      return false;
    }
  }

  /// Skip onboarding (also marks as complete)
  Future<bool> skipOnboarding() async {
    return await completeOnboarding();
  }
}
