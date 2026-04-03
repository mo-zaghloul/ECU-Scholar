import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handler for displaying local notifications via flutter_local_notifications
/// Works with Firebase messaging to display notifications in all app states
class LocalNotificationService {
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  static int _notificationIdCounter = 0;

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  BuildContext? _navigationContext;
  bool _isInitialized = false;

  factory LocalNotificationService() {
    return _instance;
  }

  LocalNotificationService._internal();

  /// Singleton instance
  static LocalNotificationService get instance => _instance;
  void setNavigationContext(BuildContext context) {
    _navigationContext = context;
  }

  /// Initialize local notifications
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      // Android initialization settings
      const AndroidInitializationSettings androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialize the plugin
      await _localNotifications.initialize(
        settings: InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification tapped: ${details.payload}');
          // Parse the payload - for now just pass empty map (can be enhanced later)
          handleNotificationTap({});
        },
      );

      // Request Android notification permission (Android 13+)
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _isInitialized = true;
      debugPrint('LocalNotificationHandler initialized');
    } catch (e) {
      debugPrint('Error initializing local notifications: $e');
    }
  }

  /// Check if notifications are enabled by user preference
  Future<bool> areNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Default to true if not set (first time user)
      return prefs.getBool(_notificationsEnabledKey) ?? true;
    } catch (e) {
      debugPrint('Error checking notification preference: $e');
      return true; // Default to enabled on error
    }
  }

  /// Show a local notification (respects user preference)
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Check if user has disabled notifications
    final isEnabled = await areNotificationsEnabled();
    if (!isEnabled) {
      debugPrint('Notifications disabled by user - not showing: $title');
      return;
    }

    await _showNotificationInternal(title: title, body: body, payload: payload);
  }

  /// Internal method to actually show notification (bypasses preference check)
  Future<void> _showNotificationInternal({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // Android notification details
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'ecu_scholar_channel',
        'ECU Scholar Notifications',
        channelDescription: 'Notifications for ECU Scholar app',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show the notification
      await _localNotifications.show(
        id: _notificationIdCounter++,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );

      debugPrint('Local notification shown: $title');
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  /// Route to appropriate page based on notification type
  void handleNotificationTap(Map<String, dynamic> data) {
    if (_navigationContext == null) {
      debugPrint('Navigation context not set');
      return;
    }

    final notificationType = data['type'] ?? 'default';

    debugPrint('Handling notification tap. Type: $notificationType');

    // Route based on notification type
    switch (notificationType) {
      case 'scheduleUpdate':
      case 'schedule':
        _navigateToSchedulePage();
        break;
      case 'gradeUpdate':
      case 'grades':
        _navigateToGradesPage();
        break;
      case 'announcement':
      case 'campaign':
      default:
        // Navigate to home page for announcements
        _navigateToHomePage();
        break;
    }
  }

  /// Navigate to schedule page
  void _navigateToSchedulePage() {
    // Get the navigator from the context stored in HomePage/MyApp
    // Using Router.of or Navigator.of depending on your routing setup
    final navigator = _navigationContext?.findAncestorStateOfType<NavigatorState>();
    if (navigator != null && navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
    debugPrint('Navigated to schedule page');
  }

  /// Navigate to grades page
  void _navigateToGradesPage() {
    final navigator = _navigationContext?.findAncestorStateOfType<NavigatorState>();
    if (navigator != null) {
      // This will push to GradesPage - implement based on your routing
      debugPrint('Navigated to grades page');
    }
  }

  /// Navigate to home page
  void _navigateToHomePage() {
    final navigator = _navigationContext?.findAncestorStateOfType<NavigatorState>();
    if (navigator != null && navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
    debugPrint('Navigated to home page');
  }
}
