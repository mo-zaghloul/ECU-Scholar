import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../services/notification_service/remote_notification_service.dart';
import '../themes/theme_provider.dart';
import '../view_models/auth_viewmodel.dart';
import '../view_models/student_viewmodel.dart';
import 'home_page.dart';

/// Processing page shown during auth initialization.
/// Displays animated status messages while backend scrapes data.
class AuthProcessingPage extends StatefulWidget {
  final String sessionToken;

  const AuthProcessingPage({
    super.key,
    required this.sessionToken,
  });

  @override
  State<AuthProcessingPage> createState() => _AuthProcessingPageState();
}

class _AuthProcessingPageState extends State<AuthProcessingPage>
    with SingleTickerProviderStateMixin {
  static const List<_StatusMessage> _statusMessages = [
    _StatusMessage('Analyzing schedule data...', Duration(milliseconds: 2000)),
    _StatusMessage('Syncing with university system...', Duration(milliseconds: 2000)),
    _StatusMessage('Loading your profile...', Duration(milliseconds: 2000)),
    _StatusMessage('Almost ready...', Duration(milliseconds: 2000)),
  ];

  int _currentMessageIndex = 0;
  Timer? _messageTimer;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  bool _isProcessing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupShimmerAnimation();
    _startMessageRotation();
    // Defer auth initialization until after the first frame is built
    // This prevents "setState() called during build" errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuth();
    });
  }

  void _setupShimmerAnimation() {
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  void _startMessageRotation() {
    _messageTimer?.cancel();
    _messageTimer = Timer.periodic(
      const Duration(milliseconds: 2000),
      (timer) {
        if (!_isProcessing) {
          timer.cancel();
          return;
        }
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _statusMessages.length;
        });
      },
    );
  }

  Future<void> _initializeAuth() async {
    try {
      final authViewModel = context.read<AuthViewModel>();
      final result = await authViewModel.initializeWithToken(widget.sessionToken);

      if (!mounted) return;

      if (result.success && result.student != null) {
        // Stop the message rotation
        _messageTimer?.cancel();
        
        // Populate StudentViewModel with the student data from auth/init
        context.read<StudentViewModel>().setStudent(result.student!);

        // Request notification permissions after successful auth
        try {
          await RemoteNotificationService.instance.requestPermissions();
        } catch (e) {
          debugPrint('Error requesting notification permissions: $e');
          // Don't block navigation if permissions fail
        }
        
        // Navigate to home on success
        _navigateToHome();
      } else {
        _messageTimer?.cancel();
        setState(() {
          _isProcessing = false;
          _errorMessage = result.errorMessage ?? 'Failed to initialize session';
        });
      }
    } catch (e) {
      if (mounted) {
        _messageTimer?.cancel();
        setState(() {
          _isProcessing = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
  }

  void _retryAuth() {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _currentMessageIndex = 0;
    });
    _startMessageRotation();
    _initializeAuth();
  }

  void _goBack() {
    Navigator.of(context).pop(false);
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _isProcessing ? _buildProcessingContent(isDark, theme) : _buildErrorContent(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingContent(bool isDark, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated Logo
        AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.3),
                    Colors.white,
                    Colors.white.withValues(alpha: 0.3),
                  ],
                  stops: [
                    _shimmerAnimation.value - 0.3,
                    _shimmerAnimation.value,
                    _shimmerAnimation.value + 0.3,
                  ].map((s) => s.clamp(0.0, 1.0)).toList(),
                ).createShader(bounds);
              },
              blendMode: BlendMode.modulate,
              child: child,
            );
          },
          child: SvgPicture.asset(
            isDark
                ? 'assets/images/logo/dark-theme-no-bg.svg'
                : 'assets/images/logo/light-theme-no-bg.svg',
            height: 80,
          ),
        ),
        const SizedBox(height: 48),

        // Animated Status Text
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            _statusMessages[_currentMessageIndex].text,
            key: ValueKey(_currentMessageIndex),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),

        // Progress Dots
        _buildProgressDots(theme),
      ],
    );
  }

  Widget _buildProgressDots(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_statusMessages.length, (index) {
        final isActive = index <= _currentMessageIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildErrorContent(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 64,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 24),
        Text(
          'Something went wrong',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _errorMessage ?? 'Please try again',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: _goBack,
              child: const Text('Go Back'),
            ),
            const SizedBox(width: 16),
            FilledButton(
              onPressed: _retryAuth,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusMessage {
  final String text;
  final Duration duration;

  const _StatusMessage(this.text, this.duration);
}
