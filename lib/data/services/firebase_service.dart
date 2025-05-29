import 'dart:developer';
import 'package:find_them/data/models/notification.dart';
import 'package:find_them/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('📱 Background message received: ${message.messageId}');
  // Handle background message - you can store to local storage if needed
  // Don't call Flutter UI methods here as the app might not be running
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Callbacks for handling notifications
  Function(NotificationModel)? onNotificationReceived;
  Function(NotificationModel)? onNotificationTapped;
  Function(String)? onTokenRefresh;

  // Navigation callback for handling notification taps
  Function(Map<String, dynamic>)? onNavigationRequested;

  // Basic initialization (permissions and local notifications only)
  Future<void> initializeBasic() async {
    if (_isInitialized) return;

    try {
      // Only initialize local notifications
      await _initializeLocalNotifications();
      log(
        '✅ Firebase Service - Basic initialization completed (local notifications only)',
      );
    } catch (e) {
      log('❌ Error in basic Firebase Service initialization: $e');
    }
  }

  // Full initialization after successful authentication
  Future<void> initializeWithAuth() async {
    try {
      log('🚀 Starting full Firebase Service initialization after auth...');

      // Request permissions
      await _requestPermissions();

      // Get FCM token
      await _getFCMToken();

      // Set up message handlers (ONLY ONCE - this is the key fix)
      if (!_isInitialized) {
        _setupMessageHandlers();

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          log('🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');
          _fcmToken = newToken;
          onTokenRefresh?.call(newToken);
        });
      }

      _isInitialized = true;
      log('✅ Firebase Service fully initialized with authentication');
    } catch (e) {
      log('❌ Error in full Firebase Service initialization: $e');
      throw e;
    }
  }

  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('✅ User granted notification permissions');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('⚠️ User granted provisional notification permissions');
    } else {
      log('❌ User declined or has not accepted notification permissions');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleLocalNotificationTap(response.payload);
      },
    );

    // Create notification channel for Android
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _createNotificationChannel();
    }
  }

  Future<void> _createNotificationChannel() async {
    const androidNotificationChannel = AndroidNotificationChannel(
      'findthem_notifications',
      'FindThem Notifications',
      description: 'Notifications for FindThem app',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        log('🔑 FCM Token obtained: ${_fcmToken!.substring(0, 20)}...');
      } else {
        log('❌ Failed to obtain FCM token');
      }
    } catch (e) {
      log('❌ Error getting FCM token: $e');
      throw e;
    }
  }

  void _setupMessageHandlers() {
    log('🔧 Setting up Firebase message handlers...');

    // Handle foreground messages - SINGLE HANDLER
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📱 Foreground FCM message received: ${message.messageId}');
      log('📱 Title: ${message.notification?.title}');
      log('📱 Body: ${message.notification?.body}');

      final notification = _createNotificationFromMessage(message);
      log('📱 New notification received: ${notification.title}');

      // Show local notification when app is in foreground
      _showLocalNotification(message);

      // Log the data for debugging
      log('📱 Data: ${message.data}');

      // Notify listeners
      onNotificationReceived?.call(notification);
    });

    // Handle message tapped when app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('📱 Message tapped (background): ${message.messageId}');
      _handleMessageTap(message);
    });

    // Handle message tapped when app is terminated and opened from notification
    _handleInitialMessage();

    log('✅ Firebase message handlers configured');
  }

  Future<void> _handleInitialMessage() async {
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      log(
        '📱 App opened from terminated state via notification: ${initialMessage.messageId}',
      );
      _handleMessageTap(initialMessage);
    }
  }

  void _handleMessageTap(RemoteMessage message) {
    log('📱 Handling notification tap from Firebase message');
    final notification = _createNotificationFromMessage(message);

    // Extract navigation data from message
    final navigationData = _extractNavigationData(message);
    log('🧭 Navigation data: $navigationData');

    // Trigger navigation
    if (onNavigationRequested != null && navigationData.isNotEmpty) {
      onNavigationRequested!(navigationData);
    }

    // Also notify other listeners
    onNotificationTapped?.call(notification);
  }

  void _handleLocalNotificationTap(String? payload) {
    if (payload != null) {
      log('📱 Local notification tapped with payload: $payload');

      final context = navigatorKey.currentContext;
      log('🧭 Navigator context available: ${context != null}');

      if (context != null) {
        log('🔍 Checking payload content...');

        if (payload.contains('location_request')) {
          log('✅ Found location_request in payload');
          log('🧭 Navigating to location sharing');
          Navigator.of(context).pushNamed('/location-sharing');
        } else if (payload.contains('location_response')) {
          log('✅ Found location_response in payload');
          log('🧭 Navigating to location sharing');
          Navigator.of(context).pushNamed('/location-sharing');
        } else if (payload.contains('location_alert')) {
          log('✅ Found location_alert in payload');
          log('🧭 Navigating to location sharing');
          Navigator.of(context).pushNamed('/location-sharing');
        } else if (payload.contains('missing_person')) {
          log('✅ Found missing_person in payload');
          log('🧭 Navigating to notifications');
          Navigator.of(context).pushNamed('/notifications');
        } else if (payload.contains('case_update')) {
          log('✅ Found case_update in payload');
          log('🧭 Navigating to submitted cases');
          Navigator.of(context).pushNamed('/submitted-cases');
        } else {
          log('⚠️ No matching notification type found in payload');
          log('🧭 Default navigation to notifications');
          Navigator.of(context).pushNamed('/notifications');
        }
      } else {
        log('❌ No navigator context available');
      }
    } else {
      log('❌ Payload is null');
    }
  }

  Map<String, dynamic> _extractNavigationData(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);

    return {
      'notification_type': data['notification_type'] ?? 'system',
      'target_id': data['target_id'],
      'request_id': data['request_id'],
      'case_id': data['case_id'],
      'report_id': data['report_id'],
      'sender_id': data['sender_id'],
      'sender_name': data['sender_name'],
      'action': data['action'],
    };
  }

  NotificationModel _createNotificationFromMessage(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);

    // Add message content to data
    if (message.notification != null) {
      data['title'] = message.notification!.title ?? '';
      data['body'] = message.notification!.body ?? '';
    }

    return NotificationModel.fromPushPayload(data);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'findthem_notifications',
      'FindThem Notifications',
      channelDescription: 'Notifications for FindThem app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
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

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      notification.title ?? 'FindThem',
      notification.body ?? 'New notification',
      notificationDetails,
      payload: message.data.toString(),
    );

    log('📱 Local notification displayed: ${notification.title}');
  }

  // Set navigation callback
  void setNavigationCallback(Function(Map<String, dynamic>) callback) {
    onNavigationRequested = callback;
  }

  // Public methods
  Future<String?> getToken() async {
    if (!_isInitialized) {
      log(
        '⚠️ Firebase Service not fully initialized, attempting to get token anyway...',
      );
      await _getFCMToken();
    }
    return _fcmToken;
  }

  Future<void> subscribeToTopic(String topic) async {
    if (!_isInitialized) {
      log(
        '⚠️ Firebase Service not initialized, cannot subscribe to topic: $topic',
      );
      return;
    }

    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      log('✅ Subscribed to topic: $topic');
    } catch (e) {
      log('❌ Error subscribing to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      log('❌ Error unsubscribing from topic $topic: $e');
    }
  }

  Future<void> clearNotifications() async {
    await _localNotifications.cancelAll();
    log('🧹 Local notifications cleared');
  }

  // Reset service (for logout)
  void reset() {
    _fcmToken = null;
    _isInitialized = false;
    onNotificationReceived = null;
    onNotificationTapped = null;
    onTokenRefresh = null;
    onNavigationRequested = null;

    // IMPORTANT: Clear any existing listeners to prevent duplicates
    // Note: FCM listeners can't be directly cancelled, but we can track initialization
    log('🔄 Firebase Service reset');
  }

  void dispose() {
    reset();
    log('🗑️ Firebase Service disposed');
  }
}
