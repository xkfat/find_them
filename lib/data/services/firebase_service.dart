// services/firebase_service.dart
import 'dart:developer';
import 'package:find_them/data/models/notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Background message received: ${message.messageId}');
  
  // Handle background message - you can store to local storage if needed
  // Don't call Flutter UI methods here as the app might not be running
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // Callbacks for handling notifications
  Function(NotificationModel)? onNotificationReceived;
  Function(NotificationModel)? onNotificationTapped;
  Function(String)? onTokenRefresh;

  Future<void> initialize() async {
    try {
      // Request permissions
      await _requestPermissions();
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Get FCM token
      await _getFCMToken();
      
      // Set up message handlers
      _setupMessageHandlers();
      
      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        log('FCM Token refreshed: ${newToken.substring(0, 20)}...');
        _fcmToken = newToken;
        onTokenRefresh?.call(newToken);
      });

      log('Firebase Service initialized successfully');
    } catch (e) {
      log('Error initializing Firebase Service: $e');
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
      log('User granted notification permissions');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      log('User granted provisional notification permissions');
    } else {
      log('User declined or has not accepted notification permissions');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
        _handleNotificationTap(response.payload);
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
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        log('FCM Token obtained: ${_fcmToken!.substring(0, 20)}...');
      }
    } catch (e) {
      log('Error getting FCM token: $e');
    }
  }

  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Foreground message received: ${message.messageId}');
      _handleForegroundMessage(message);
    });

    // Handle message tapped when app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('Message tapped (background): ${message.messageId}');
      _handleMessageTap(message);
    });

    // Handle message tapped when app is terminated and opened from notification
    _handleInitialMessage();
  }

  Future<void> _handleInitialMessage() async {
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      log('App opened from terminated state via notification: ${initialMessage.messageId}');
      _handleMessageTap(initialMessage);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = _createNotificationFromMessage(message);
    
    // Show local notification when app is in foreground
    _showLocalNotification(message);
    
    // Notify listeners
    onNotificationReceived?.call(notification);
  }

  void _handleMessageTap(RemoteMessage message) {
    final notification = _createNotificationFromMessage(message);
    onNotificationTapped?.call(notification);
  }

  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      // Handle local notification tap
      // You can parse the payload to get notification data
      log('Local notification tapped with payload: $payload');
    }
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

    final notificationType = message.data['notification_type'] ?? 'system';
    
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
  }

  // Public methods
  Future<String?> getToken() async {
    if (_fcmToken == null) {
      await _getFCMToken();
    }
    return _fcmToken;
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      log('Subscribed to topic: $topic');
    } catch (e) {
      log('Error subscribing to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Error unsubscribing from topic $topic: $e');
    }
  }

  Future<void> clearNotifications() async {
    await _localNotifications.cancelAll();
  }

  void dispose() {
    // Clean up resources if needed
  }
}