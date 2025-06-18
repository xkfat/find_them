import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:find_them/data/dataprovider/exception.dart';
import 'package:find_them/data/services/api_service.dart';
import 'package:find_them/data/services/notification_service.dart';
import 'package:find_them/data/services/prefrences_service.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final ApiService _apiService;
  final NotificationService _notificationService = NotificationService();
  final ProfilePreferencesService _preferencesService =
      ProfilePreferencesService();

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
        String myres = utf8.decode(response.bodyBytes);
        var responseJson = json.decode(myres);
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

      // Parse the response
      Map<String, dynamic> responseJson;
      try {
        responseJson = json.decode(response.body);
      } catch (e) {
        log("❌ Error parsing JSON: $e");
        return {"error": "Invalid response from server"};
      }

      // Handle different status codes
      switch (response.statusCode) {
        case 200:
          // Success - check if tokens exist
          if (responseJson.containsKey('access') &&
              responseJson.containsKey('refresh')) {
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

        case 400:
          // Validation error
          log("❌ Bad request (400)");
          return responseJson; // Return the error message from Django

        case 401:
          // Wrong credentials
          log("❌ Unauthorized (401)");
          return responseJson; // Return the error message from Django

        case 403:
          log("❌ Forbidden (403)");
          return {"msg": "Access forbidden"};

        default:
          log("❌ Unexpected status: ${response.statusCode}");
          return {"msg": "Login failed with status: ${response.statusCode}"};
      }
    } on SocketException catch (e) {
      log("❌ Socket exception - network error: $e");
      return {"msg": "Network error: Check your internet connection"};
    } on TimeoutException catch (e) {
      log("❌ Request timeout: $e");
      return {"msg": "Connection timed out"};
    } on ClientException catch (e) {
      log("❌ Client exception: $e");
      return {"msg": "Client error: ${e.message}"};
    } catch (e) {
      log("❌ Unexpected error: $e");
      return {"msg": "An unexpected error occurred"};
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
      log("🔐 Simple signup test for: $username");

      final response = await http.post(
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
      );

      log("📡 Response: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {"error": "Signup failed", "status": response.statusCode};
      }
    } catch (e) {
      log("❌ Error: $e");
      return {"error": e.toString()};
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

Future<dynamic> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    String? password,
  }) async {
    try {
      log("🔄 Attempting to update profile for: $username");

      // Get the current access token
      final accessToken = await _apiService.getAccessToken();
      
      if (accessToken == null) {
        throw Exception('No access token available');
      }

      final requestBody = {
        "first_name": firstName,
        "last_name": lastName,
        "username": username,
        "email": email,
        "phone_number": phoneNumber,
      };

      // Only add password if provided
      if (password != null && password.isNotEmpty) {
        requestBody["password"] = password;
      }

      final response = await http.patch(
        Uri.parse('http://10.0.2.2:8000/api/accounts/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      ).timeout(Duration(seconds: 60));

      log("📡 Profile update response status: ${response.statusCode}");
      log("📡 Profile update response body: ${response.body}");

      dynamic responseJson = _response(response);

      if (response.statusCode == 200) {
        log("✅ Profile updated successfully for: $username");
        return responseJson;
      } else {
        throw Exception('Profile update failed');
      }
    } catch (e) {
      log("❌ Profile update error: $e");
      rethrow;
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
          await _preferencesService.clearCachedPreferences();

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
