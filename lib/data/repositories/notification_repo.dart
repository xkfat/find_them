// repositories/notification_repository.dart
import 'dart:convert';
import 'dart:developer';
import 'package:find_them/data/models/notification.dart';
import 'package:find_them/data/services/api_service.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart'; // Assume you have this
import '../../core/constants/api_constants.dart'; // Your API constants

class NotificationRepository {
  static const String _baseUrl =
      ApiConstants.baseUrl; // e.g., 'https://your-api.com/api'
  final ApiService _apiService = ApiService(); // Your auth service

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
      log('Error getting notifications: $e');
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
      log('Error getting notification: $e');
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
      log('Error deleting notification: $e');
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
      log('Error clearing notifications: $e');
      return false;
    }
  }

  // Update FCM token
  Future<bool> updateFCMToken(String token) async {
    try {
      final response = await _apiService.authenticatedRequest(() async {
        final headers = await _headers;
        return http.post(
          Uri.parse(
            'http://10.0.2.2:8000/api/accounts/update-fcm-token/',
          ), // Adjust endpoint as needed
          headers: headers,
          body: json.encode({'fcm_token': token}),
        );
      });

      if (response.statusCode == 200) {
        log('FCM token updated successfully');
        return true;
      } else {
        log('Failed to update FCM token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('Error updating FCM token: $e');
      return false;
    }
  }

  // Remove FCM token (for logout)
  Future<bool> removeFCMToken() async {
    try {
      final response = await _apiService.authenticatedRequest(() async {
        final headers = await _headers;
        return http.delete(
          Uri.parse(
            'http://10.0.2.2:8000/api/accounts/remove-fcm-token/',
          ), // Adjust endpoint as needed
          headers: headers,
        );
      });

      return response.statusCode == 200;
    } catch (e) {
      log('Error removing FCM token: $e');
      return false;
    }
  }

  // Check FCM status
  Future<Map<String, dynamic>> checkFCMStatus() async {
    try {
      final response = await _apiService.authenticatedRequest(() async {
        final headers = await _headers;
        return http.get(
          Uri.parse(
            'http://10.0.2.2:8000/api/accounts/check-fcm-status/',
          ), // Adjust endpoint as needed
          headers: headers,
        );
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'has_fcm_token': false};
      }
    } catch (e) {
      log('Error checking FCM status: $e');
      return {'has_fcm_token': false};
    }
  }

  Future<void> syncFCMTokenWithServer(String fcmToken) async {
    try {
      final token = await _apiService.getAccessToken();
      print('🔑 Access token being sent: ${token?.substring(0, 30)}...');

      print('📤 Sending FCM token to Django: ${fcmToken.substring(0, 30)}...');
      print(
        '📤 Request URL: http://10.0.2.2:8000/api/accounts/update-fcm-token/',
      );

      final response = await _apiService.authenticatedRequest(() async {
        final headers = await _headers;
        return http.post(
          Uri.parse('http://10.0.2.2:8000/api/accounts/update-fcm-token/'),
          headers: headers,
          body: jsonEncode({'fcm_token': token}),
        );
      });

      print('📨 Django response status: ${response.statusCode}');
      print('📨 Django response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ FCM token synced with Django successfully');
      } else {
        print('❌ Failed to sync FCM token: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error syncing FCM token: $e');
    }
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
