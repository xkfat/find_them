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

  Function(List<NotificationModel>)? onNotificationsUpdated;
  Function(int)? onUnreadCountChanged;
  Function(NotificationModel)? onNewNotification;

  Future<void> initialize() async {
    if (_isBasicInitialized) return;

    try {
      await _firebaseService.initializeBasic();

      _isBasicInitialized = true;
      log('✅ Notification Service - Basic initialization completed');
    } catch (e) {
      log('❌ Error in basic notification service initialization: $e');
    }
  }

  Future<void> initializeAfterAuth() async {
    if (_isFullyInitialized) {
      log('🔄 Notification Service already fully initialized');
      return;
    }

    try {
      log('🚀 Starting full notification service initialization after auth...');

      await _firebaseService.initializeWithAuth();

      _firebaseService.onTokenRefresh = _handleTokenRefresh;

      await _syncFCMTokenWithServer();

      await _firebaseService.subscribeToTopic('all_users');

      _isFullyInitialized = true;
      log('✅ Notification Service fully initialized after authentication');
    } catch (e) {
      log('❌ Error in full notification service initialization: $e');
      throw e;
    }
  }

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

  Future<void> refreshNotifications() async {
    await getNotifications();
  }

  Future<void> _handleTokenRefresh(String newToken) async {
    log('🔄 FCM Token refreshed, syncing with server...');
    try {
      await _repository.syncFCMTokenWithServer(newToken);
      log('✅ New FCM token synced with server');
    } catch (e) {
      log('❌ Error syncing refreshed token: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    if (!_isFullyInitialized) {
      log('⚠️ Cannot subscribe to topic - service not fully initialized');
      return;
    }
    await _firebaseService.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseService.unsubscribeFromTopic(topic);
  }

  Future<void> clearLocalNotifications() async {
    await _firebaseService.clearNotifications();
  }

  Future<void> removeFCMToken() async {
    try {
      await _repository.removeFCMToken();
      log('✅ FCM token removed from server');
    } catch (e) {
      log('❌ Error removing FCM token: $e');
    }
  }

  Future<bool> hasFCMToken() async {
    try {
      final status = await _repository.checkFCMStatus();
      return status['has_fcm_token'] ?? false;
    } catch (e) {
      log('❌ Error checking FCM status: $e');
      return false;
    }
  }

  Future<String?> getFCMToken() async {
    return await _firebaseService.getToken();
  }

  Future<void> reset() async {
    try {
      await removeFCMToken();

      await clearLocalNotifications();

      await unsubscribeFromTopic('all_users');

      _firebaseService.reset();

      _isFullyInitialized = false;

      onNotificationsUpdated = null;
      onUnreadCountChanged = null;
      onNewNotification = null;

      log('🔄 Notification Service reset completed');
    } catch (e) {
      log('❌ Error resetting notification service: $e');
    }
  }

  void dispose() {
    _firebaseService.dispose();
    log('🗑️ Notification Service disposed');
  }

  bool get isBasicInitialized => _isBasicInitialized;
  bool get isFullyInitialized => _isFullyInitialized;
}
