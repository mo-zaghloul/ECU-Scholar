import 'package:ecu_scholar/view_models/auth_viewmodel.dart';
import 'package:ecu_scholar/view_models/student_viewmodel.dart';
import 'package:ecu_scholar/views/auth_page.dart';
import 'package:ecu_scholar/views/feedback_page.dart';
import 'package:ecu_scholar/widgets/settings_group_card.dart';
import 'package:ecu_scholar/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../themes/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'Version ${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthViewModel>().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCE1407),
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _openInstapayLink() async {
    // Replace with your actual Instapay link
    final Uri url = Uri.parse('https://ipn.eg/S/ecuscholar/instapay/hsoECg');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final student = Provider.of<StudentViewModel>(context).studentData;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.almarai(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Header Section
            _buildProfileHeader(student, colorScheme),

            const SizedBox(height: 24),

            // Preferences Section
            SettingsGroupCard(
              children: [
                SettingsToggleTile(
                  icon: Icons.notifications_outlined,
                  iconBackgroundColor: const Color(0xFFFF3B30),
                  title: 'Notifications',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    // TODO: Implement notifications toggle logic
                  },
                ),
                SettingsToggleTile(
                  icon: Icons.dark_mode_outlined,
                  iconBackgroundColor: const Color(0xFF5856D6),
                  title: 'Dark Mode',
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
              ],
            ),

            // Help Improve App Section
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 24, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'HELP IMPROVE APP',
                  style: GoogleFonts.almarai(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SettingsGroupCard(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                SettingsTile(
                  icon: Icons.feedback_outlined,
                  iconBackgroundColor: const Color(0xFF34C759),
                  title: 'Send Feedback',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FeedbackPage(
                          feedbackType: FeedbackType.feedback,
                        ),
                      ),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.bug_report_outlined,
                  iconBackgroundColor: const Color(0xFFFF9500),
                  title: 'Report a Bug',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FeedbackPage(
                          feedbackType: FeedbackType.bug,
                        ),
                      ),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.favorite_outline,
                  iconBackgroundColor: const Color(0xFFCE1407),
                  title: 'Support Hosting',
                  subtitle: 'Help keep the app running',
                  onTap: _openInstapayLink,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Logout Section
            SettingsGroupCard(
              children: [
                SettingsTile(
                  icon: Icons.logout,
                  iconBackgroundColor: Colors.grey,
                  title: 'Log Out',
                  showChevron: false,
                  isDestructive: true,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // App Version
            Text(
              _appVersion,
              style: GoogleFonts.almarai(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(student, ColorScheme colorScheme) {
    final String initials = _getInitials(student.name);

    return Column(
      children: [
        // Avatar with initials
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF7A7ACA), // Light purple like Apple's
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: GoogleFonts.almarai(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Name
        Text(
          student.name.trim().split(' ').take(2).join(' '), // Show only first and second name
          style: GoogleFonts.almarai(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        // Faculty/Email
        Text(
          student.faculty,
          style: GoogleFonts.almarai(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
