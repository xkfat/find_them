import 'package:dio/dio.dart';
import 'package:find_them/core/constants/api_constants.dart';
import 'package:find_them/data/models/notification.dart';
import 'package:find_them/data/services/api_service.dart';

class NotificationService {
  late Dio dio;

  NotificationService(ApiService apiService) {
    dio = apiService.dio;
  }

  Future<List<Notification>?> getNotifications() async {
    try {
      Response response = await dio.get(ApiConstants.notifications);
      
      return (response.data as List)
          .map((json) => Notification.fromJson(json))
          .toList();
    } catch (e) {
      return null;
    }
  }


   Future<Notification?> viewNotification(int id) async {
    try {
      String url = ApiConstants.viewNotification.replaceAll('{id}', id.toString());
      Response response = await dio.get(url);
      
      return Notification.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}