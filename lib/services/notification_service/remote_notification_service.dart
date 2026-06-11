import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'local_notification_service.dart';

/// Service for managing Firebase Cloud Messaging (FCM) and remote push notifications
/// Handles foreground, background, and terminated app notification states
class RemoteNotificationService {
  static final RemoteNotificationService _instance = RemoteNotificationService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  String? _fcmToken;
  bool _isInitialized = false;

  RemoteNotificationService._internal();

  /// Singleton instance
  static RemoteNotificationService get instance => _instance;

  /// Whether the notification service has been initialized
  bool get isInitialized => _isInitialized;

  /// Get the current FCM token (or request a new one if not available)
  Future<String?> getFCMToken() async {
    if (_fcmToken != null && _fcmToken!.isNotEmpty) {
      debugPrint('Using cached FCM token: $_fcmToken');
      return _fcmToken;
    }

    try {
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM token obtained: $_fcmToken');
      return _fcmToken;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Request notification permissions from the user (iOS)
  /// Android 13+ will show permission dialog automatically
  Future<NotificationSettings> requestPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      debugPrint('Notification permission status: ${settings.authorizationStatus}');
      return settings;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return await _firebaseMessaging.getNotificationSettings();
    }
  }

  /// Initialize the notification service and setup handlers
  /// Must be called once on app startup
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('RemoteNotificationService already initialized');
      return;
    }

    try {
      // Initialize local notifications handler first
      await LocalNotificationService().initialize();

      // Get FCM token for initial setup
      await getFCMToken();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message (static handler)
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle notification tap when app is in background or terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was launched by tapping a notification
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App launched from notification tap');
        _handleNotificationTap(initialMessage);
      }

      _isInitialized = true;
      debugPrint('RemoteNotificationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing RemoteNotificationService: $e');
    }
  }

    /// Handle foreground messages - show as local notification/toast
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // 1. Log incoming payload variables for easier debugging
    debugPrint('Foreground message received. Notification Obj: ${message.notification?.title}');
    debugPrint('Data map payload: ${message.data}');

    // Check if user has enabled notifications before showing
    final isEnabled = await LocalNotificationService().areNotificationsEnabled();
    if (!isEnabled) {
      debugPrint('Notifications disabled - received but not showing.');
      return;
    }

    // 2. Safely extract strings from either 'data' (Backend) or 'notification' (Console)
    final String title = message.data['title'] ?? message.notification?.title ?? 'Notification';
    final String body = message.data['body'] ?? message.notification?.body ?? '';

    // If both parameters evaluate completely empty, skip displaying an alert window
    if (title == 'Notification' && body.isEmpty) {
      debugPrint('Skipping empty message wrapper.');
      return;
    }

    // Display local notification even though app is in foreground
    await LocalNotificationService().showNotification(
      title: title,
      body: body,
      payload: _encodePayload(message.data),
    );
  }

  /// Handle notification tap - navigate to appropriate page
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.notification?.title}');
    debugPrint('Data: ${message.data}');

    // Navigate based on notification type
    LocalNotificationService().handleNotificationTap(message.data);
  }

  /// Delete the FCM token (called on logout)
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      debugPrint('FCM token deleted');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }

  /// Unsubscribe from all topics
  Future<void> unsubscribeAll() async {
    try {
      // Add any topic unsubscriptions here if needed
      debugPrint('Unsubscribed from all topics');
    } catch (e) {
      debugPrint('Error unsubscribing: $e');
    }
  }

  /// Bridge the payload map to JSON string for local notifications
  static String _encodePayload(Map<String, dynamic> data) {
    // Simple encoding of notification data for passing to local notification handler
    return data.toString();
  }
}

/// Static handler for background messages (called when app is in background or terminated)
/// Must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received.');
  debugPrint('Notification Obj: ${message.notification?.title}');
  debugPrint('Data map payload: ${message.data}');

  // If message.notification is NOT null, the phone OS has already automatically
  // displayed this notification in the system tray. We must exit early to prevent a double notification.
  if (message.notification != null) {
    debugPrint('OS already handled showing this background notification. Exiting handler.');
    return;
  }

  // 1. Extract variables safely from the data payload (e.g. your Python script)
  final String title = message.data['title'] ?? 'Notification';
  final String body = message.data['body'] ?? '';

  if (body.isEmpty && title == 'Notification') {
    return; // Don't show empty alerts
  }

  // 2. Initialize local notifications in the background isolated process
  await LocalNotificationService().initialize();

  // 3. Show notification in tray (Only hits this line for data-only payloads like Python)
  await LocalNotificationService().showNotification(
    title: title,
    body: body,
    payload: message.data.toString(),
  );
}

