import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:find_them/data/dataprovider/exception.dart';
import 'package:find_them/data/services/api_service.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final ApiService _apiService;

  AuthService({ApiService? apiService})       : _apiService = apiService ?? ApiService();


 

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
      log("attewmpting login for : $username");

      final response = await http
          .post(
            Uri.parse('http://10.0.2.2:8000/api/accounts/login/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"username": username, "password": Pwd}),
          )
          .timeout(Duration(seconds: 60));
      log(response.statusCode.toString());
      log(response.body);

      responseJson = _response(response);

      if (response.statusCode == 200  &&
             responseJson['access'] != null && 
          responseJson['refresh'] != null) {
        await _apiService.saveAuthTokens(
          accessToken: responseJson['access'],
          refreshToken: responseJson['refresh'],
          userData: responseJson['user'] ?? {},
        );
      }
         return responseJson;

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseJson.containsKey('access') && responseJson.containsKey('refresh')) {
           await _apiService.saveAuthTokens(
            accessToken: responseJson['access'],
            refreshToken: responseJson['refresh'],
            userData: responseJson['user'] ?? {},
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
    await _apiService.clearAuthTokens();        return {'success': true};
      } else {
        return {'success': false, 'message': 'Failed to delete account'};
      }
    } catch (e) {
      log("Error in delete account: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  // Add a method to log out
  Future<bool> logout() async {
    try {
      // You might want to call a logout endpoint on your API here if needed
      // For now, we'll just clear the tokens
      await _apiService.clearAuthTokens();
      return true;
    } catch (e) {
      log("Error logging out: $e");
      return false;
    }
  }
}