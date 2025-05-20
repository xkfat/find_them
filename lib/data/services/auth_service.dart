import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
//import 'package:dio/dio.dart';
import 'package:find_them/data/dataprovider/exception.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // final ApiService _apiService;
  //static const String _authDataKey = 'auth_data';

  AuthService();
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

  Future<dynamic> login(String username, String Pwd) async {
    dynamic responseJson;
    try {
      print("logi");

      var response = await http
          .post(
            Uri.parse('http://10.0.2.2:8000/api/accounts/login/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"username": username, "password": Pwd}),
          )
          .timeout(Duration(seconds: 60));
      log(response.statusCode.toString());
      log(response.body);

      responseJson = _response(response);
    } on BadRequestException {
      log("bad 400");
      throw Failure();
    } on TimeoutException {
      log("timeout");
      throw Failure();
    } on SocketException {
      log("Socket");
      throw Failure();
    } on ClientException {
      log("ClientException ");
      throw Failure();
    } on UnauthorisedException {
      log("401-3");
      throw Failure(code: 1);
    } on NotFoundException {
      log("404");
      throw Failure();
    } on FetchDataException {
      
      log("FetchData");
      throw Failure(message: "Erreur fetch data:");
    }

    return responseJson;
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
      log("signup");

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
      log("Signup response status: ${response.statusCode}");
      log("Signup response body: ${response.body}");

      Map<String, dynamic> responseJson;
      try {
        responseJson = json.decode(response.body);
      } catch (e) {
        log("Error parsing JSON: $e");
        responseJson = {"message": response.body};
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
      log("Socket Exception: $e");
      throw Failure(message: "Network error: Check your internet connection");
    } on TimeoutException catch (e) {
      log("Timeout Exception: $e");
      throw Failure(message: "Connection timed out");
    } on ClientException catch (e) {
      log("Client Exception: $e");
      throw Failure(message: "Client error: ${e.message}");
    } catch (e) {
      log("Unexpected error: $e");
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
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Failed to delete account'};
      }
    } catch (e) {
      log("Error in delete account: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  /*
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


  

  Future<AuthData?> authenticateWithFirebase(
    firebase_auth.UserCredential credential,
  ) async {
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
/*
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
*/
  Future<User?> getCurrentUser() async {
    try {
      final authData = await getAuthData();
      return authData?.user;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
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

  
  
  */
}
