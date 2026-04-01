import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    super.initState();
    // Initialize auth on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().initialize();
    });
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

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
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
                  ],
                ),

                // Footer terms text
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Text(
                    'By continuing you agree to the\nTerms of Service and Privacy Policy',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.4),
                      height: 1.6,
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
