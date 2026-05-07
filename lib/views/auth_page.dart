import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../view_models/auth_viewmodel.dart';
import 'auth_webview_page.dart';
import 'home_page.dart';

/// Landing page for authentication.
/// Shows login options and handles navigation based on auth state.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;
  late final TextEditingController _devTokenController;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _openExternalLink(
            'https://ecu-scholar-web-6zcw.vercel.app/terms',
          );
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _openExternalLink(
            'https://ecu-scholar-web-6zcw.vercel.app/privacy',
          );
    _devTokenController = TextEditingController();
    // Rebuild when token text changes to update button state
    _devTokenController.addListener(() {
      setState(() {});
    });
    // Initialize auth on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    _devTokenController.dispose();
    super.dispose();
  }

  Future<void> _openAuthBrowser() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AuthWebViewPage()),
    );

    // If authentication was successful, navigate to home
    if (result == true && mounted) {
      _navigateToHome();
    }
  }

  Future<void> _submitDevToken(BuildContext context, AuthViewModel authViewModel) async {
    final token = _devTokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a token')),
      );
      return;
    }

    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Testing token...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );
    }

    // Try to authenticate with the provided token
    final result = await authViewModel.loginWithToken(token);
    
    if (result.success && mounted) {
      _devTokenController.clear();
      _navigateToHome();
    } else if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Authentication failed'),
          backgroundColor: const Color(0xFFCE1407),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  Future<void> _openExternalLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          // Handle different auth states
          switch (authViewModel.state) {
            case AuthState.loading:
            case AuthState.initial:
            case AuthState.processing:
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading...'),
                  ],
                ),
              );
            
            case AuthState.authenticated:
              // Auto-navigate to home when authenticated
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _navigateToHome();
              });
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 64, color: Colors.green),
                    SizedBox(height: 16),
                    Text('Authenticated! Redirecting...'),
                  ],
                ),
              );
            
            case AuthState.unauthenticated:
            case AuthState.error:
              return _buildLoginContent(context, authViewModel);
          }
        },
      ),
    );
  }

  Widget _buildLoginContent(BuildContext context, AuthViewModel authViewModel) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF000000),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                  MediaQuery.of(context).padding.top,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 1),

                // Main content column
                Column(
                  children: [
                    // Logo and text group
                    Column(
                      children: [
                        // Large centered logo
                        SvgPicture.asset(
                          'assets/images/logo/dark-theme-no-bg.svg',
                          height: 170,
                          width: 170,
                        ),
                        const SizedBox(height: 12),

                        // App name with serif display font
                        Text(
                          'ECU Scholar',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Tagline with modern sans-serif
                        Text(
                          'Your university life, finally organized.',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.6),
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 48),

                    // Error message if any
                    if (authViewModel.state == AuthState.error &&
                        authViewModel.errorMessage != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCE1407).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFCE1407).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, 
                                  color: Color(0xFFCE1407), size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    authViewModel.errorMessage!,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Login Button
                    ClipRRect(
                      borderRadius: BorderRadius.circular(29),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCE1407),
                            borderRadius: BorderRadius.circular(29),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFC61D28).withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _openAuthBrowser,
                              borderRadius: BorderRadius.circular(29),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.login_rounded, 
                                      color: Colors.white, size: 22),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Login with ECU SIS',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Dev Mode Token Input (only in debug mode)
                    if (kDebugMode) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.developer_mode, 
                                  color: Colors.blue, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Dev Mode - Quick Login',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _devTokenController,
                              decoration: InputDecoration(
                                hintText: 'Paste session token/cookie...',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.05),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                              maxLines: 3,
                              minLines: 1,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: Material(
                                color: Colors.blue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: _devTokenController.text.isNotEmpty
                                      ? () => _submitDevToken(context, authViewModel)
                                      : null,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Center(
                                    child: Text(
                                      'Test Login',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _devTokenController.text.isNotEmpty
                                            ? Colors.blue
                                            : Colors.blue.withValues(alpha: 0.5),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                // Footer terms text
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Text.rich(
                    TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.4),
                        height: 1.6,
                      ),
                      children: [
                        const TextSpan(
                          text: 'By continuing you agree to the\n',
                        ),
                        TextSpan(
                          text: 'Terms of Use',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.4),
                            height: 1.6,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withValues(alpha: 0.4),
                            decorationThickness: 1.1,
                          ),
                          recognizer: _termsRecognizer,
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.4),
                            height: 1.6,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withValues(alpha: 0.4),
                            decorationThickness: 1.1,
                          ),
                          recognizer: _privacyRecognizer,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
