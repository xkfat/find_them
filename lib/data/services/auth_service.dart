import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:find_them/data/dataprovider/exception.dart';
import 'package:find_them/data/services/api_service.dart';
import 'package:find_them/data/services/notification_service.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final ApiService _apiService;
  final NotificationService _notificationService = NotificationService();

  AuthService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  dynamic _response(http.Response response) {
    switch (response.statusCode) {
      case 200:
        String myres = utf8.decode(response.bodyBytes);
        var responseJson = json.decode(myres);
        return responseJson;
      case 204:
        return response;
      case 205:
        return response;
      case 201:
        String res = json.decode(response.body);
        var responseJson = json.decode(res);
        log("success response: $responseJson");
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
        throw UnauthorisedException(response.body.toString());
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
          'Error occured while Communication with Server with StatusCode: ${response.statusCode}',
        );
    }
  }

  Future<dynamic> login(String username, String pwd) async {
    dynamic responseJson;
    try {
      log("🔐 Attempting login for: $username");

      final response = await http
          .post(
            Uri.parse('http://10.0.2.2:8000/api/accounts/login/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"username": username, "password": pwd}),
          )
          .timeout(Duration(seconds: 60));

      log("📡 Login response status: ${response.statusCode}");
      log("📡 Login response body: ${response.body}");

      responseJson = _response(response);

      if (response.statusCode == 200 &&
          responseJson['access'] != null &&
          responseJson['refresh'] != null) {
        await _apiService.saveAuthTokens(
          accessToken: responseJson['access'],
          refreshToken: responseJson['refresh'],
          userData: responseJson['user'] ?? {},
        );

        await _initializeNotificationsAfterAuth(username);

        log(
          "✅ Login successful and notifications initialized for user: $username",
        );
      }
      return responseJson;
    } on BadRequestException {
      log("❌ Bad request (400)");
      throw Failure();
    } on TimeoutException {
      log("❌ Request timeout");
      throw Failure();
    } on SocketException {
      log("❌ Socket exception - network error");
      throw Failure();
    } on ClientException {
      log("❌ Client exception");
      throw Failure();
    } on UnauthorisedException {
      log("❌ Unauthorized (401/403)");
      throw Failure(code: 1);
    } on NotFoundException {
      log("❌ Not found (404)");
      throw Failure();
    } on FetchDataException {
      log("❌ Fetch data exception");
      throw Failure(message: "Error fetching data");
    }
  }

  Future<dynamic> signup({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      log("🔐 Attempting signup for: $username");

      var response = await http
          .post(
            Uri.parse('http://10.0.2.2:8000/api/accounts/signup/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "first_name": firstName,
              "last_name": lastName,
              "username": username,
              "email": email,
              "phone_number": phoneNumber,
              "password": password,
              "password2": passwordConfirmation,
            }),
          )
          .timeout(Duration(seconds: 60));

      log("📡 Signup response status: ${response.statusCode}");
      log("📡 Signup response body: ${response.body}");

      Map<String, dynamic> responseJson;
      try {
        responseJson = json.decode(response.body);
      } catch (e) {
        log("❌ Error parsing JSON: $e");
        responseJson = {"message": response.body};
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseJson.containsKey('access') &&
            responseJson.containsKey('refresh')) {
          await _apiService.saveAuthTokens(
            accessToken: responseJson['access'],
            refreshToken: responseJson['refresh'],
            userData: responseJson['user'] ?? {},
          );

          await _initializeNotificationsAfterAuth(username);

          log(
            "✅ Signup successful and notifications initialized for user: $username",
          );
        }
      }

      switch (response.statusCode) {
        case 200:
        case 201:
          return responseJson;
        case 400:
          return responseJson;
        case 401:
        case 403:
          throw UnauthorisedException("Authentication failed");
        case 404:
          throw NotFoundException("Endpoint not found");
        case 500:
        default:
          throw FetchDataException("Server error: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      log("❌ Socket Exception: $e");
      throw Failure(message: "Network error: Check your internet connection");
    } on TimeoutException catch (e) {
      log("❌ Timeout Exception: $e");
      throw Failure(message: "Connection timed out");
    } on ClientException catch (e) {
      log("❌ Client Exception: $e");
      throw Failure(message: "Client error: ${e.message}");
    } catch (e) {
      log("❌ Unexpected error: $e");
      throw Failure(message: "An unexpected error occurred");
    }
  }

  Future<Map<String, dynamic>> deleteAccount(String username) async {
    try {
      var response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/api/accounts/delete/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"username": username}),
      );

      if (response.statusCode == 200) {
        await _cleanupUserSession();
        log("✅ Account deleted and session cleaned up for: $username");
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Failed to delete account'};
      }
    } catch (e) {
      log("❌ Error in delete account: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> logout() async {
    try {
      final accessToken = await _apiService.getAccessToken();
      final refreshToken = await _apiService.getRefreshToken();

      if (refreshToken == null) {
        log("⚠️ No refresh token available, performing local cleanup only");
        await _cleanupUserSession();
        return true;
      }

      try {
        final response = await http
            .post(
              Uri.parse('http://10.0.2.2:8000/api/accounts/logout/'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $accessToken',
              },
              body: jsonEncode({"refresh": refreshToken}),
            )
            .timeout(Duration(seconds: 60));

        log("📡 Logout response status: ${response.statusCode}");

        if (response.statusCode == 200 || response.statusCode == 204) {
          await _cleanupUserSession();
          log("✅ Server logout successful - session cleaned up");
          return true;
        }

        if (response.statusCode == 401) {
          log("🔄 Access token expired, attempting to refresh before logout");
          final refreshed = await _apiService.refreshToken();

          if (refreshed) {
            final newAccessToken = await _apiService.getAccessToken();

            final retryResponse = await http
                .post(
                  Uri.parse('http://10.0.2.2:8000/api/accounts/logout/'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $newAccessToken',
                  },
                  body: jsonEncode({"refresh": refreshToken}),
                )
                .timeout(Duration(seconds: 60));

            log("📡 Retry logout response status: ${retryResponse.statusCode}");
            await _cleanupUserSession();
            log("✅ Retry logout completed - session cleaned up");
            return true;
          }
        }

        await _cleanupUserSession();
        log("⚠️ Server logout failed but local cleanup completed");
        return true;
      } catch (e) {
        log("❌ Error during server logout: $e");
        await _cleanupUserSession();
        log("⚠️ Server logout failed but local cleanup completed");
        return true;
      }
    } catch (e) {
      log("❌ Unexpected error in logout: $e");
      try {
        await _cleanupUserSession();
        log("✅ Emergency logout cleanup completed");
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  Future<void> _initializeNotificationsAfterAuth(String username) async {
    try {
      log("🚀 Initializing notifications after successful auth for: $username");

      await _notificationService.initialize();

      await _notificationService.initializeAfterAuth();

      log("✅ Notification service fully initialized for user: $username");
    } catch (e) {
      log("❌ Error initializing notifications after auth: $e");
    }
  }

  Future<void> _cleanupUserSession() async {
    try {
      log("🧹 Starting user session cleanup...");

      await _notificationService.reset();

      await _apiService.clearAuthTokens();

      log("✅ User session cleanup completed");
    } catch (e) {
      log("❌ Error during session cleanup: $e");
      try {
        await _apiService.clearAuthTokens();
        log("⚠️ Auth tokens cleared despite notification cleanup failure");
      } catch (_) {
        log("❌ Failed to clear auth tokens during cleanup");
      }
    }
  }

  Future<void> restoreNotificationToken() async {
    try {
      final accessToken = await _apiService.getAccessToken();

      if (accessToken != null) {
        log("🔄 Restoring notification service for existing session");

        await _notificationService.initialize();

        await _initializeNotificationsAfterAuth("existing_user");

        log("✅ Notification service restored successfully");
      }
    } catch (e) {
      log("❌ Error restoring notification token: $e");
    }
  }

  Future<String?> getFCMToken() async {
    return await _notificationService.getFCMToken();
  }

  Future<bool> hasValidFCMToken() async {
    return await _notificationService.hasFCMToken();
  }

  Future<void> syncFCMToken() async {
    try {
      await _notificationService.refreshNotifications();
      log("✅ FCM token sync completed");
    } catch (e) {
      log("❌ Error syncing FCM token: $e");
    }
  }

  Future<bool> isLoggedIn() async {
    return await _apiService.hasToken();
  }

  Future<String?> getToken() async {
    return await _apiService.getAccessToken();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    return await _apiService.getUserData();
  }

  Future<bool> refreshToken() async {
    return await _apiService.refreshToken();
  }

  Future<void> clearAuthData() async {
    await _apiService.clearAuthTokens();
  }
}
