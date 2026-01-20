import 'package:flutter/foundation.dart';
import '../services/onboarding_service/onboarding_service.dart';

/// Model representing a single onboarding page
class OnboardingPageData {
  final String svgAsset;
  final String titleKey;
  final String subtitleKey;

  const OnboardingPageData({
    required this.svgAsset,
    required this.titleKey,
    required this.subtitleKey,
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
  int get pageCount => pages.length;

  /// Onboarding pages data with keys for localization
  final List<OnboardingPageData> pages = const [
    OnboardingPageData(
      svgAsset: 'assets/onboarding/Smart People.svg',
      titleKey: 'onboardingTitle1',
      subtitleKey: 'onboardingDesc1',
    ),
    OnboardingPageData(
      svgAsset: 'assets/onboarding/Student Studying.svg',
      titleKey: 'onboardingTitle2',
      subtitleKey: 'onboardingDesc2',
    ),
    OnboardingPageData(
      svgAsset: 'assets/onboarding/Manager Desk.svg',
      titleKey: 'onboardingTitle3',
      subtitleKey: 'onboardingDesc3',
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
