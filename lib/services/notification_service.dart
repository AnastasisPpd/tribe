import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global navigator key for notification tap handling
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Singleton service for managing push notifications
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _prefsKey = 'notifications_enabled';

  bool _isInitialized = false;
  bool _isEnabled = false;
  String? _currentChatId;

  // Callback for handling notification taps
  void Function(String activityId, String activityTitle)? onNotificationTap;

  /// Current chat ID being viewed (to suppress notifications for it)
  String? get currentChatId => _currentChatId;
  set currentChatId(String? value) => _currentChatId = value;

  /// Whether notifications are enabled
  bool get isEnabled => _isEnabled;

  /// Initialize the notification service
  Future<void> init() async {
    if (_isInitialized) return;

    // Load preference
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_prefsKey) ?? false;

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      // Payload format: "activityId|activityTitle"
      final parts = payload.split('|');
      if (parts.length >= 2 && onNotificationTap != null) {
        onNotificationTap!(parts[0], parts[1]);
      }
    }
  }

  /// Request notification permissions from the OS
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
      return true;
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
      return true;
    }
    return true;
  }

  /// Set whether notifications are enabled
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, enabled);
  }

  /// Show a notification for a new chat message
  Future<void> showChatNotification({
    required String activityId,
    required String activityTitle,
    required String senderName,
    required String messageText,
  }) async {
    // Don't show if notifications disabled or user is viewing this chat
    if (!_isEnabled || _currentChatId == activityId) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use activity ID hash as notification ID to group messages per chat
    final notificationId = activityId.hashCode;

    await _notifications.show(
      notificationId,
      activityTitle,
      '$senderName: $messageText',
      notificationDetails,
      payload: '$activityId|$activityTitle',
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
