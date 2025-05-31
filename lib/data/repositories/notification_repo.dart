import 'dart:convert';
import 'dart:developer';
import 'package:find_them/data/models/notification.dart';
import 'package:find_them/data/services/api_service.dart';
import 'package:http/http.dart' as http;

class NotificationRepository {
  // ignore: unused_field
  static const String _baseUrl = 'http://10.0.2.2:8000/api/';
  final ApiService _apiService = ApiService();

  Future<Map<String, String>> get _headers async {
    final token = await _apiService.getAccessToken();
    return {
      'Content-Type': 'application/json; charset=utf-8', 
      'Accept': 'application/json; charset=utf-8',
      'Accept-Charset': 'utf-8', 
      'Authorization': 'Bearer $token',
    };
  }

  String _decodeResponse(http.Response response) {
    try {
      return utf8.decode(response.bodyBytes);
    } catch (e) {
      log("UTF-8 decoding failed, falling back to body string: $e");
      return response.body;
    }
  }

  dynamic _parseJsonResponse(http.Response response) {
    try {
      final decodedBody = _decodeResponse(response);
      return json.decode(decodedBody);
    } catch (e) {
      log("JSON parsing error: $e");
      throw Exception('Failed to parse server response');
    }
  }

  Future<List<NotificationModel>> getNotifications({String? type}) async {
    try {
      String url = 'http://10.0.2.2:8000/api/notifications/';

      if (type != null) {
        url += '?type=${Uri.encodeComponent(type)}';
      }

      final response = await _apiService.authenticatedRequest(() async {
        final headers = await _headers;
        return http.get(Uri.parse(url), headers: headers);
      });

      if (response.statusCode == 200) {
        final data = _parseJsonResponse(response);
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
        final data = _parseJsonResponse(response);
        return NotificationModel.fromJson(data);
      } else {
        throw Exception('Failed to load notification: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error getting notification: $e');
      throw Exception('Network error: $e');
    }
  }

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

  Future<bool> syncFCMTokenWithServer(String fcmToken) async {
    try {
      log('🔄 Syncing FCM token with Django server...');
      log('📤 FCM token: ${fcmToken.substring(0, 30)}...');

      final response = await _apiService.authenticatedRequest(() async {
        final headers = await _headers;
        log(
          '🔑 Authorization header: ${headers['Authorization']?.substring(0, 30)}...',
        );

        return http.post(
          Uri.parse('http://10.0.2.2:8000/api/accounts/update-fcm-token/'),
          headers: headers,
          body: jsonEncode({'fcm_token': fcmToken}),
        );
      });

      log('📨 Django response status: ${response.statusCode}');
      log('📨 Django response body: ${_decodeResponse(response)}');

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
        return _parseJsonResponse(response);
      } else {
        return {'has_fcm_token': false};
      }
    } catch (e) {
      log('❌ Error checking FCM status: $e');
      return {'has_fcm_token': false};
    }
  }

  Future<bool> updateFCMToken(String token) async {
    return await syncFCMTokenWithServer(token);
  }

  Future<List<NotificationModel>> getNotificationsByType(String type) async {
    return getNotifications(type: type);
  }

  Future<List<NotificationModel>> markNotificationsAsRead() async {
    return getNotifications(); 
  }
}
