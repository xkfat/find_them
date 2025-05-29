// repositories/notification_repository.dart - Modified for post-auth FCM sync
import 'dart:convert';
import 'dart:developer';
import 'package:find_them/data/models/notification.dart';
import 'package:find_them/data/services/api_service.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class NotificationRepository {
  static const String _baseUrl = ApiConstants.baseUrl;
  final ApiService _apiService = ApiService();

  Future<Map<String, String>> get _headers async {
    final token = await _apiService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all notifications for current user
  Future<List<NotificationModel>> getNotifications({String? type}) async {
    try {
      String url = 'http://10.0.2.2:8000/api/notifications/';

      if (type != null) {
        url += '?type=$type';
      }

      final response = await _apiService.authenticatedRequest(() async {
        final headers = await _headers;
        return http.get(Uri.parse(url), headers: headers);
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final notifications = data['notifications'] as List? ?? data as List;

        return notifications
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error getting notifications: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get specific notification
  Future<NotificationModel> getNotification(int id) async {
    try {
      final response = await _apiService.authenticatedRequest(() async {
        final headers = await _headers;
        return http.get(
          Uri.parse('http://10.0.2.2:8000/api/notifications/$id/'),
          headers: headers,
        );
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NotificationModel.fromJson(data);
      } else {
        throw Exception('Failed to load notification: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error getting notification: $e');
      throw Exception('Network error: $e');
    }
  }

  // Delete specific notification
  Future<bool> deleteNotification(int id) async {
    try {
      final response = await _apiService.authenticatedRequest(() async {
        final headers = await _headers;
        return http.delete(
          Uri.parse('http://10.0.2.2:8000/api/notifications/$id/delete/'),
          headers: headers,
        );
      });

      return response.statusCode == 204;
    } catch (e) {
      log('❌ Error deleting notification: $e');
      return false;
    }
  }

  // Clear all notifications
  Future<bool> clearAllNotifications() async {
    try {
      final response = await _apiService.authenticatedRequest(() async {
        final headers = await _headers;
        return http.delete(
          Uri.parse('http://10.0.2.2:8000/api/notifications/clear-all/'),
          headers: headers,
        );
      });

      return response.statusCode == 200;
    } catch (e) {
      log('❌ Error clearing notifications: $e');
      return false;
    }
  }

  // Sync FCM token with server (called after successful auth)
  Future<bool> syncFCMTokenWithServer(String fcmToken) async {
    try {
      log('🔄 Syncing FCM token with Django server...');
      log('📤 FCM token: ${fcmToken.substring(0, 30)}...');

      final response = await _apiService.authenticatedRequest(() async {
        final headers = await _headers;
        log('🔑 Authorization header: ${headers['Authorization']?.substring(0, 30)}...');
        
        return http.post(
          Uri.parse('http://10.0.2.2:8000/api/accounts/update-fcm-token/'),
          headers: headers,
          body: jsonEncode({'fcm_token': fcmToken}),
        );
      });

      log('📨 Django response status: ${response.statusCode}');
      log('📨 Django response body: ${response.body}');

      if (response.statusCode == 200) {
        log('✅ FCM token synced with Django successfully');
        return true;
      } else {
        log('❌ Failed to sync FCM token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('❌ Error syncing FCM token: $e');
      return false;
    }
  }

  // Remove FCM token (for logout)
  Future<bool> removeFCMToken() async {
    try {
      log('🗑️ Removing FCM token from server...');
      
      final response = await _apiService.authenticatedRequest(() async {
        final headers = await _headers;
        return http.delete(
          Uri.parse('http://10.0.2.2:8000/api/accounts/remove-fcm-token/'),
          headers: headers,
        );
      });

      log('📨 Remove FCM token response: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        log('✅ FCM token removed from server successfully');
        return true;
      } else {
        log('❌ Failed to remove FCM token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('❌ Error removing FCM token: $e');
      return false;
    }
  }

  // Check FCM status
  Future<Map<String, dynamic>> checkFCMStatus() async {
    try {
      final response = await _apiService.authenticatedRequest(() async {
        final headers = await _headers;
        return http.get(
          Uri.parse('http://10.0.2.2:8000/api/accounts/check-fcm-status/'),
          headers: headers,
        );
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'has_fcm_token': false};
      }
    } catch (e) {
      log('❌ Error checking FCM status: $e');
      return {'has_fcm_token': false};
    }
  }

  // Legacy method - kept for backward compatibility
  Future<bool> updateFCMToken(String token) async {
    return await syncFCMTokenWithServer(token);
  }

  // Get filtered notifications by type
  Future<List<NotificationModel>> getNotificationsByType(String type) async {
    return getNotifications(type: type);
  }

  // Mark notifications as read (handled automatically by backend when fetching)
  Future<List<NotificationModel>> markNotificationsAsRead() async {
    return getNotifications(); // Backend marks as read when fetching
  }
}