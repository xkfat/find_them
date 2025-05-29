// services/notification_service.dart - Modified to initialize after auth
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

  bool _isBasicInitialized = false;
  bool _isFullyInitialized = false;

  // Callbacks for real-time updates
  Function(List<NotificationModel>)? onNotificationsUpdated;
  Function(int)? onUnreadCountChanged;
  Function(NotificationModel)? onNewNotification;

  // Basic initialization (only local notifications, no FCM)
  Future<void> initialize() async {
    if (_isBasicInitialized) return;

    try {
      // Only initialize basic Firebase functionality (local notifications)
      await _firebaseService.initializeBasic();
      
      _isBasicInitialized = true;
      log('✅ Notification Service - Basic initialization completed');
    } catch (e) {
      log('❌ Error in basic notification service initialization: $e');
    }
  }

  // Full initialization after successful authentication
  Future<void> initializeAfterAuth() async {
    if (_isFullyInitialized) {
      log('🔄 Notification Service already fully initialized');
      return;
    }

    try {
      log('🚀 Starting full notification service initialization after auth...');
      
      // Initialize Firebase with authentication
      await _firebaseService.initializeWithAuth();

      // Set up Firebase callbacks
      _firebaseService.onNotificationReceived = _handleNewNotification;
      _firebaseService.onNotificationTapped = _handleNotificationTapped;
      _firebaseService.onTokenRefresh = _handleTokenRefresh;

      // Get and sync FCM token with server
      await _syncFCMTokenWithServer();

      // Subscribe to general topics
      await _firebaseService.subscribeToTopic('all_users');

      _isFullyInitialized = true;
      log('✅ Notification Service fully initialized after authentication');
    } catch (e) {
      log('❌ Error in full notification service initialization: $e');
      throw e;
    }
  }

  // Sync FCM token with server
  Future<void> _syncFCMTokenWithServer() async {
    try {
      final token = await _firebaseService.getToken();
      if (token != null) {
        log('🔄 Syncing FCM token with server: ${token.substring(0, 20)}...');
        await _repository.syncFCMTokenWithServer(token);
        log('✅ FCM token synced with server successfully');
      } else {
        log('❌ No FCM token available to sync');
      }
    } catch (e) {
      log('❌ Error syncing FCM token with server: $e');
      throw e;
    }
  }

  // Get all notifications
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final notifications = await _repository.getNotifications();
      onNotificationsUpdated?.call(notifications);
      return notifications;
    } catch (e) {
      log('❌ Error getting notifications: $e');
      return [];
    }
  }

  // Get specific notification
  Future<NotificationModel?> getNotification(int id) async {
    try {
      return await _repository.getNotification(id);
    } catch (e) {
      log('❌ Error getting notification: $e');
      return null;
    }
  }

 Future<bool> deleteNotification(int id) async {
  try {
    log('🗑️ Attempting to delete notification $id');
    
    final success = await _repository.deleteNotification(id);
    
    if (success) {
      log('✅ Notification $id deleted from server');
      
      // Don't refresh automatically here - let the cubit handle UI updates
      // This prevents unnecessary API calls
      return true;
    } else {
      log('❌ Failed to delete notification $id from server');
      return false;
    }
  } catch (e) {
    log('❌ Error deleting notification $id: $e');
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
      log('❌ Error clearing notifications: $e');
      return false;
    }
  }

  // Refresh notifications
  Future<void> refreshNotifications() async {
    await getNotifications();
  }

  // Handle new notification from push
  void _handleNewNotification(NotificationModel notification) {
    log('📱 New notification received: ${notification.title}');
    onNewNotification?.call(notification);
  }

  // Handle notification tap
  void _handleNotificationTapped(NotificationModel notification) {
    log('📱 Notification tapped: ${notification.title}');
  }

  // Handle FCM token refresh
  Future<void> _handleTokenRefresh(String newToken) async {
    log('🔄 FCM Token refreshed, syncing with server...');
    try {
      await _repository.syncFCMTokenWithServer(newToken);
      log('✅ New FCM token synced with server');
    } catch (e) {
      log('❌ Error syncing refreshed token: $e');
    }
  }

  // Subscribe to topic (for admin broadcasts, etc.)
  Future<void> subscribeToTopic(String topic) async {
    if (!_isFullyInitialized) {
      log('⚠️ Cannot subscribe to topic - service not fully initialized');
      return;
    }
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
      log('✅ FCM token removed from server');
    } catch (e) {
      log('❌ Error removing FCM token: $e');
    }
  }

  // Check if user has FCM token registered
  Future<bool> hasFCMToken() async {
    try {
      final status = await _repository.checkFCMStatus();
      return status['has_fcm_token'] ?? false;
    } catch (e) {
      log('❌ Error checking FCM status: $e');
      return false;
    }
  }

  // Get FCM token
  Future<String?> getFCMToken() async {
    return await _firebaseService.getToken();
  }

  // Reset service (for logout)
  Future<void> reset() async {
    try {
      // Remove FCM token from server
      await removeFCMToken();
      
      // Clear local notifications
      await clearLocalNotifications();
      
      // Unsubscribe from topics
      await unsubscribeFromTopic('all_users');
      
      // Reset Firebase service
      _firebaseService.reset();
      
      // Reset flags
      _isFullyInitialized = false;
      
      // Clear callbacks
      onNotificationsUpdated = null;
      onUnreadCountChanged = null;
      onNewNotification = null;
      
      log('🔄 Notification Service reset completed');
    } catch (e) {
      log('❌ Error resetting notification service: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _firebaseService.dispose();
    log('🗑️ Notification Service disposed');
  }

  // Check initialization status
  bool get isBasicInitialized => _isBasicInitialized;
  bool get isFullyInitialized => _isFullyInitialized;
}