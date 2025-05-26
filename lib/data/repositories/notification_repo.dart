import 'package:find_them/data/models/notification.dart';
import 'package:find_them/data/services/api_service.dart';
import 'package:find_them/data/services/notification_service.dart';

class NotificationRepository {
  final NotificationService _service;
  final ApiService _apiService;

  NotificationRepository(this._service) : _apiService = ApiService();

  Future<String?> getAuthToken() async {
    return await _apiService.getAccessToken();
  }

  Future<List<NotificationModel>> getNotifications({String? type}) async {
    try {
      final token = await getAuthToken();
      return await _service.getNotifications(type: type, token: token);
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  Future<NotificationModel> getNotificationById(int id) async {
    try {
      final token = await getAuthToken();
      return await _service.getNotificationById(id, token: token);
    } catch (e) {
      throw Exception('Failed to get notification: $e');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final token = await getAuthToken();
      await _service.markAsRead(notificationId, token: token);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
 Future<void> deleteNotification(int notificationId) async {
    try {
      final token = await getAuthToken();
      await _service.deleteNotification(notificationId, token: token);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }
}
