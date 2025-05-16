import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:find_them/core/constants/api_constants.dart';
import 'package:find_them/data/models/auth.dart';
import 'package:find_them/data/models/user.dart';
import 'package:find_them/data/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthService {
  final ApiService _apiService;
  late Dio dio;
  static const String _authDataKey = 'auth_data';

  AuthService(this._apiService) {
    dio = _apiService.dio;
  }

  static const _publicHeaders = {'Content-Type': 'application/json'};

  Future<Response<dynamic>> _postPublic(String url, Map<String, dynamic> data) {
    return dio.post(
      url,
      data: data,
      options: Options(headers: _publicHeaders), 
    );
  }


  Future<AuthData?> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = prefs.getString(_authDataKey);

    if (encodedData == null) {
      return null;
    }

    try {
      final decodedData = json.decode(encodedData);
      return AuthData.fromJson(decodedData);
    } catch (e) {
      print('Error parsing auth data: $e');
      return null;
    }
  }

  Future<void> _saveAuthData(AuthData authData) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = json.encode(authData.toJson());
    await prefs.setString(_authDataKey, encodedData);
    await _apiService.setAuthToken(authData.token);
  }


  Future<AuthData> loginWithCredentials(LoginCredentials credentials) async {
    try {
      print('Attempting login with username: ${credentials.username}');
      print('Request URL: ${dio.options.baseUrl}${ApiConstants.login}');
      print('Request data: ${credentials.toJson()}');

      await _apiService.clearAuthToken();

      Response response = await dio.post(
        ApiConstants.login,
        data: credentials.toJson(),
      );

      print('Login successful, processing response');
      print('Response data: ${response.data}');

      final authData = AuthData.fromJson(response.data);
      await _saveAuthData(authData);
      return authData;
    } catch (e) {
      print('Login error: $e');
      if (e is DioError && e.response != null) {
        print('Response status: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<AuthData> signup(SignUpData data) async {
    try {
      print('Attempting signup for user: ${data.username}');
      print('Request URL: ${dio.options.baseUrl}${ApiConstants.signup}');
      print('Request data: ${data.toJson()}');

      Response response = await dio.post(
        ApiConstants.signup,
        data: data.toJson(),
      );

      print('Signup successful, processing response');
      print('Response data: ${response.data}');

      final authData = AuthData.fromJson(response.data);
      await _saveAuthData(authData);
      return authData;
    } catch (e) {
      print('Signup error: $e');
      if (e is DioError && e.response != null) {
        print('Response status: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  Future<bool> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      print('Attempting to change password');
      Response response = await dio.post(
        ApiConstants.changePassword,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password2': confirmPassword,
        },
      );

      print('Password change response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Password change error: $e');
      return false;
    }
  }

  
  Future<AuthData?> authenticateWithFirebase(firebase_auth.UserCredential credential) async {
    try {
      print('Getting Firebase ID token');
      final idToken = await credential.user?.getIdToken();

      if (idToken == null) {
        print('Failed to get Firebase ID token');
        throw Exception('Failed to get Firebase ID token');
      }

      print('Sending Firebase token to backend');
      final response = await dio.post(
        ApiConstants.firebaseAuth,
        data: {
          'id_token': idToken,
          'provider': credential.credential?.providerId ?? 'firebase',
          'uid': credential.user?.uid ?? '',
          'display_name': credential.user?.displayName ?? '',
          'email': credential.user?.email ?? '',
          'phone_number': credential.user?.phoneNumber ?? '',
          'photo_url': credential.user?.photoURL ?? '',
        },
      );

      print('Backend authentication successful, processing response');
      final authData = AuthData.fromJson(response.data);
      await _saveAuthData(authData);
      return authData;
    } catch (e) {
      print('Firebase authentication error with backend: $e');
      throw Exception('Firebase authentication failed: ${e.toString()}');
    }
  }


  Future<bool> isAuthenticated() async {
    try {
      final authData = await getAuthData();
      if (authData == null) {
        print('No authentication data found');
        return false;
      }

      if (authData.isExpired) {
        print('Auth token expired, attempting refresh');
        final refreshToken = authData.refreshToken;
        if (refreshToken.isNotEmpty) {
          return await _refreshToken(refreshToken);
        }
        return false;
      }

      print('User is authenticated, setting auth token');
      await _apiService.setAuthToken(authData.token);
      return true;
    } catch (e) {
      print('Error checking authentication: $e');
      return false;
    }
  }

  Future<bool> _refreshToken(String refreshToken) async {
    try {
      print('Attempting to refresh token');
      Response response = await dio.post(
        ApiConstants.tokenRefresh,
        data: {'refresh': refreshToken},
      );

      print('Token refresh successful');
      final authData = await getAuthData();
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
      print('Token refresh error: $e');
      return false;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final authData = await getAuthData();
      return authData?.user;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      print('Logging out user');
      await dio.post(ApiConstants.logout);
    } catch (e) {
      print('API logout error (continuing with local logout): $e');
    } finally {
      print('Clearing local auth data');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authDataKey);
      await _apiService.clearAuthToken();
      
      print('Logout complete');
    }
  }
}