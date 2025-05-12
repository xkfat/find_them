import 'package:dio/dio.dart';
import 'package:find_them/core/constants/api_constants.dart';

class ApiService {
  late Dio dio;

  ApiService() {
    BaseOptions options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: Duration(seconds: 20),
      receiveTimeout: Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    );
    dio = Dio(options);
  }

  Future<void> setAuthToken(String token) async {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> clearAuthToken() async {
    dio.options.headers.remove('Authorization');
  }
}
