import 'package:flutter/material.dart';
import 'package:ecu_scholar/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../constants/text_styles.dart';
import '../view_models/onboarding_viewmodel.dart';
import 'auth_page.dart';

/// Onboarding page with swipeable screens and animations.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    context.read<OnboardingViewModel>().setCurrentPage(page);
  }

  void _nextPage(OnboardingViewModel viewModel) {
    if (viewModel.isLastPage) {
      _completeOnboarding(viewModel);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding(OnboardingViewModel viewModel) async {
    await viewModel.skipOnboarding();
    if (mounted) {
      _navigateToAuth();
    }
  }

  void _completeOnboarding(OnboardingViewModel viewModel) async {
    await viewModel.completeOnboarding();
    if (mounted) {
      _navigateToAuth();
    }
  }

  void _navigateToAuth() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
          const AuthPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  String _getLocalizedTitle(AppLocalizations l10n, int index) {
    switch (index) {
      case 0:
        return l10n.onboardingTitle1;
      case 1:
        return l10n.onboardingTitle2;
      case 2:
        return l10n.onboardingTitle3;
      default:
        return '';
    }
  }

  String _getLocalizedSubtitle(AppLocalizations l10n, int index) {
    switch (index) {
      case 0:
        return l10n.onboardingDesc1;
      case 1:
        return l10n.onboardingDesc2;
      case 2:
        return l10n.onboardingDesc3;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Consumer<OnboardingViewModel>(
        builder: (context, viewModel, child) {
          return SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextButton(
                        onPressed: viewModel.isCompleting
                            ? null
                            : () => _skipOnboarding(viewModel),
                        child: Text(
                          l10n.skip,
                          style: AppTextStyles.bodyText1.copyWith(
                            color: colorScheme.inversePrimary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: viewModel.pages.length,
                      itemBuilder: (context, index) {
                        final pageData = viewModel.pages[index];
                        final isDarkMode = colorScheme.brightness == Brightness.dark;
                        return _OnboardingPageContent(
                          svgAsset: pageData.getSvgAsset(isDarkMode),
                          title: _getLocalizedTitle(l10n, index),
                          subtitle: _getLocalizedSubtitle(l10n, index),
                          isActive: index == viewModel.currentPage,
                          colorScheme: colorScheme,
                        );
                      },
                    ),
                  ),

                  // Page indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: viewModel.pages.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: colorScheme.error,
                        dotColor: colorScheme.inversePrimary.withValues(alpha: 0.3),
                        dotHeight: 10,
                        dotWidth: 10,
                        expansionFactor: 3,
                        spacing: 8,
                      ),
                    ),
                  ),

                  // Next/Get Started button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: viewModel.isCompleting
                            ? null
                            : () => _nextPage(viewModel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: viewModel.isCompleting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    viewModel.isLastPage
                                        ? l10n.getStarted
                                        : l10n.next,
                                    style: AppTextStyles.subtitle1bold.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (!viewModel.isLastPage) ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, size: 20),
                                  ],
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Individual onboarding page content with animations
class _OnboardingPageContent extends StatefulWidget {
  final String svgAsset;
  final String title;
  final String subtitle;
  final bool isActive;
  final ColorScheme colorScheme;

  const _OnboardingPageContent({
    required this.svgAsset,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.colorScheme,
  });

  @override
  State<_OnboardingPageContent> createState() => _OnboardingPageContentState();
}

class _OnboardingPageContentState extends State<_OnboardingPageContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    if (widget.isActive) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(_OnboardingPageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SVG Illustration with scale animation
          ScaleTransition(
            scale: _scaleAnimation,
            child: SvgPicture.asset(
              widget.svgAsset,
              height: MediaQuery.of(context).size.height * 0.35,
              fit: BoxFit.contain,
            ),
          ),
          
          const SizedBox(height: 48),

          // Title with slide animation
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _animationController,
              child: Text(
                widget.title,
                style: AppTextStyles.headline2.copyWith(
                  color: widget.colorScheme.primary,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Subtitle with slide animation (delayed)
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.3, 1.0),
              ),
              child: Text(
                widget.subtitle,
                style: AppTextStyles.bodyText1.copyWith(
                  color: widget.colorScheme.inversePrimary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
