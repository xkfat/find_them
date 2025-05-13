import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:find_them/core/constants/api_constants.dart';
import 'package:find_them/data/models/auth.dart';
import 'package:find_them/data/models/user.dart';
import 'package:find_them/data/services/api_service.dart';

class AuthService {
  late Dio dio;
  static const String _authDataKey = 'auth_data';
  final ApiService _apiService;

  AuthService(this._apiService) {
    dio = _apiService.dio;
  }

  Future<AuthData?> _getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = prefs.getString(_authDataKey);

    if (encodedData == null) {
      return null;
    }

    try {
      final decodedData = json.decode(encodedData);
      return AuthData.fromJson(decodedData);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveAuthData(AuthData authData) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = json.encode(authData.toJson());
    await prefs.setString(_authDataKey, encodedData);
    await _apiService.setAuthToken(authData.token);
  }

  Future<AuthData> login(LoginCredentials credentials) async {
    try {
      Response response = await dio.post(
        ApiConstants.login,
        data: credentials.toJson(),
      );

      final authData = AuthData.fromJson(response.data);
      await _saveAuthData(authData);
      return authData;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<AuthData> signup(SignUpData data) async {
    try {
      Response response = await dio.post(
        ApiConstants.signup,
        data: data.toJson(),
      );

      final authData = AuthData.fromJson(response.data);
      await _saveAuthData(authData);
      return authData;
    } catch (e) {
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await dio.post(ApiConstants.logout);
    } catch (e) {
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authDataKey);
      await _apiService.clearAuthToken();
    }
  }

  Future<bool> isAuthenticated() async {
    final authData = await _getAuthData();
    if (authData == null || authData.isExpired) {
      final refreshToken = authData?.refreshToken;
      if (refreshToken != null) {
        return await _refreshToken(refreshToken);
      }
      return false;
    }
    await _apiService.setAuthToken(authData.token);
    return true;
  }

  Future<bool> _refreshToken(String refreshToken) async {
    try {
      Response response = await dio.post(
        ApiConstants.tokenRefresh,
        data: {'refresh': refreshToken},
      );

      final authData = await _getAuthData();
      if (authData != null) {
        final updatedAuthData = AuthData(
          token: response.data['access'],
          refreshToken: response.data['refresh'] ?? refreshToken,
          user: authData.user,
          expiryTime: DateTime.now().add(Duration(minutes: 60)),
        );

        await _saveAuthData(updatedAuthData);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<User?> getCurrentUser() async {
    final authData = await _getAuthData();
    return authData?.user;
  }
}
