// services/notification_service.dart
import 'dart:developer';
import 'package:find_them/data/models/notification.dart';
import 'package:find_them/data/repositories/notification_repo.dart';
import 'firebase_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final NotificationRepository _repository = NotificationRepository();
  final FirebaseService _firebaseService = FirebaseService();

  bool _isInitialized = false;

  // Callbacks for real-time updates
  Function(List<NotificationModel>)? onNotificationsUpdated;
  Function(int)? onUnreadCountChanged;
  Function(NotificationModel)? onNewNotification;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase (but don't sync token yet)
      await _firebaseService.initialize();

      // Set up Firebase callbacks
      _firebaseService.onNotificationReceived = _handleNewNotification;
      _firebaseService.onNotificationTapped = _handleNotificationTapped;
      _firebaseService.onTokenRefresh = _handleTokenRefresh;

      // DON'T update FCM token on server here - wait for login/signup

      _isInitialized = true;
      log('Notification Service initialized (FCM sync pending login)');
    } catch (e) {
      log('Error initializing Notification Service: $e');
    }
  }

  // NEW: Method to sync FCM token after successful login/signup
  Future<void> syncFCMTokenAfterAuth() async {
    try {
      log('🔄 Syncing FCM token after authentication...');
      await _updateFCMTokenOnServer();
    } catch (e) {
      log('Error syncing FCM token after auth: $e');
    }
  }

  // Get all notifications
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final notifications = await _repository.getNotifications();
      onNotificationsUpdated?.call(notifications);
      return notifications;
    } catch (e) {
      log('Error getting notifications: $e');
      return [];
    }
  }

  // Get specific notification
  Future<NotificationModel?> getNotification(int id) async {
    try {
      return await _repository.getNotification(id);
    } catch (e) {
      log('Error getting notification: $e');
      return null;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(int id) async {
    try {
      final success = await _repository.deleteNotification(id);
      if (success) {
        // Refresh notifications after deletion
        await refreshNotifications();
      }
      return success;
    } catch (e) {
      log('Error deleting notification: $e');
      return false;
    }
  }

  // Clear all notifications
  Future<bool> clearAllNotifications() async {
    try {
      final success = await _repository.clearAllNotifications();
      if (success) {
        onNotificationsUpdated?.call([]);
        onUnreadCountChanged?.call(0);
      }
      return success;
    } catch (e) {
      log('Error clearing notifications: $e');
      return false;
    }
  }

  // Refresh notifications
  Future<void> refreshNotifications() async {
    await getNotifications();
  }

  // Handle new notification from push
  void _handleNewNotification(NotificationModel notification) {
    log('New notification received: ${notification.title}');
    onNewNotification?.call(notification);
  }

  // Handle notification tap
  void _handleNotificationTapped(NotificationModel notification) {
    log('Notification tapped: ${notification.title}');
    
    // You can add navigation logic here or let the UI handle it
    // For example, you could use a navigation service:
    // NavigationService.navigateTo(notification.navigationRoute, notification.navigationArguments);
  }

  // Handle FCM token refresh
  Future<void> _handleTokenRefresh(String newToken) async {
    log('🔄 FCM Token refreshed, syncing with server...');
    await _repository.syncFCMTokenWithServer(newToken);
  }

  // Update FCM token on server (private method)
  Future<void> _updateFCMTokenOnServer() async {
    try {
      final token = await _firebaseService.getToken();
      if (token != null) {
        await _repository.syncFCMTokenWithServer(token);
        log('FCM token synced with server after auth');
      }
    } catch (e) {
      log('Error updating FCM token on server: $e');
    }
  }

  // Subscribe to topic (for admin broadcasts, etc.)
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseService.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseService.unsubscribeFromTopic(topic);
  }

  // Clear local notifications
  Future<void> clearLocalNotifications() async {
    await _firebaseService.clearNotifications();
  }

  // Remove FCM token (for logout)
  Future<void> removeFCMToken() async {
    try {
      await _repository.removeFCMToken();
      log('FCM token removed from server');
    } catch (e) {
      log('Error removing FCM token: $e');
    }
  }

  // Check if user has FCM token registered
  Future<bool> hasFCMToken() async {
    try {
      final status = await _repository.checkFCMStatus();
      return status['has_fcm_token'] ?? false;
    } catch (e) {
      log('Error checking FCM status: $e');
      return false;
    }
  }

  // Get FCM token
  Future<String?> getFCMToken() async {
    return await _firebaseService.getToken();
  }

  // Dispose resources
  void dispose() {
    _firebaseService.dispose();
  }
}