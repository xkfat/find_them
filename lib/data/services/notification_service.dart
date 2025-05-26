import 'dart:convert';
import 'dart:developer';
import 'package:find_them/data/dataprovider/exception.dart';
import 'package:find_them/data/models/notification.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final String baseUrl;
  final http.Client _httpClient;

  NotificationService({
    this.baseUrl = 'http://10.0.2.2:8000/api',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Map<String, String> _getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<NotificationModel>> getNotifications({String? type, String? token}) async {
    try {
      log('Fetching notifications${type != null ? ' of type: $type' : ''}');
      
      String endpoint = '$baseUrl/notifications/';
      if (type != null && type.isNotEmpty) {
        endpoint += '?type=$type';
      }
      
      final response = await _httpClient.get(
        Uri.parse(endpoint),
        headers: _getHeaders(token: token),
      );

      log('Notifications response status: ${response.statusCode}');
      log('Notifications response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw UnauthorisedException('Authentication failed');
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getting notifications: $e');
      throw Exception('Error getting notifications: $e');
    }
  }

  Future<NotificationModel> getNotificationById(int id, {String? token}) async {
    try {
      log('Fetching notification by ID: $id');
      
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/notifications/$id/'),
        headers: _getHeaders(token: token),
      );

      log('Notification detail response status: ${response.statusCode}');
      log('Notification detail response body: ${response.body}');

      if (response.statusCode == 200) {
        return NotificationModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw UnauthorisedException('Authentication failed');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Notification not found');
      } else {
        throw Exception('Failed to load notification: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getting notification: $e');
      throw Exception('Error getting notification: $e');
    }
  }

  Future<void> markAsRead(int notificationId, {String? token}) async {
    try {
      log('Marking notification as read: $notificationId');
      
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/notifications/$notificationId/'),
        headers: _getHeaders(token: token),
      );

      log('Mark as read response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read: ${response.statusCode}');
      }
    } catch (e) {
      log('Error marking notification as read: $e');
      throw Exception('Error marking notification as read: $e');
    }
  }
 Future<void> deleteNotification(int notificationId, {String? token}) async {
    try {
      log('Deleting notification: $notificationId');
      
      final response = await _httpClient.delete(
        Uri.parse('$baseUrl/notifications/$notificationId/delete/'),
        headers: _getHeaders(token: token),
      );

      log('Delete notification response status: ${response.statusCode}');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete notification: ${response.statusCode}');
      }
    } catch (e) {
      log('Error deleting notification: $e');
      throw Exception('Error deleting notification: $e');
    }
  }
}