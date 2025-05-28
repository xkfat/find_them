import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:find_them/core/constants/api_constants.dart';
import 'package:find_them/data/models/user.dart';
import 'package:find_them/data/services/api_service.dart';
import 'package:http/http.dart' as http;

class ProfileResponse {
  final bool success;
  final String message;
  final User? user;
  final Map<String, dynamic>? errors;

  ProfileResponse({
    required this.success,
    required this.message,
    this.user,
    this.errors,
  });
}

class ProfileService {
  final ApiService _apiService;

  ProfileService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<User> getUserProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.profile);
      log("Profile GET response: ${response.statusCode}");
      log("Profile GET body: ${response.body}");

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        return User.fromJson(userData);
      } else {
        final error = json.decode(response.body);
        throw ProfileException(
          error['message'] ?? 'Failed to load user profile',
          error['errors'] ?? {},
          error['user'] != null ? User.fromJson(error['user']) : null,
        );
      }
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileException('Error fetching user profile: $e', {}, null);
    }
  }

  Future<ProfileResponse> updateProfilePartial(
    Map<String, dynamic> fields,
  ) async {
    try {
      log("Updating profile with fields: $fields");
      final response = await _apiService.patch(
        ApiConstants.profile,
        body: fields,
      );

      log("Profile PATCH response: ${response.statusCode}");
      log("Profile PATCH body: ${response.body}");

      final responseData = json.decode(response.body);

      bool success = responseData['success'] ?? (response.statusCode == 200);
      String message = responseData['message'] ?? 'Profile update processed';
      User? user;

      if (responseData.containsKey('user')) {
        try {
          user = User.fromJson(responseData['user']);
        } catch (e) {
          log("Error parsing user: $e");
        }
      }

      if (!success || response.statusCode != 200) {
        return ProfileResponse(
          success: false,
          message: message,
          user: user,
          errors:
              responseData['errors'] != null
                  ? Map<String, dynamic>.from(responseData['errors'])
                  : {'general': 'Failed to update profile'},
        );
      }

      return ProfileResponse(success: true, message: message, user: user);
    } catch (e) {
      log("Exception in updateProfilePartial: $e");
      return ProfileResponse(
        success: false,
        message: 'Error in profile update: ${e.toString()}',
        errors: {'general': e.toString()},
      );
    }
  }

  Future<ProfileResponse> updateProfilePhoto(File photo) async {
    try {
      final token = await _apiService.getAccessToken();
      log(
        "Updating profile photo with token: ${token != null ? 'Valid token' : 'No token'}",
      );

      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(
        await http.MultipartFile.fromPath('profile_photo', photo.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      log("Profile photo update response: ${response.statusCode}");
      log("Profile photo update body: ${response.body}");

      final responseData = json.decode(response.body);

      bool success = responseData['success'] ?? (response.statusCode == 200);
      String message =
          responseData['message'] ?? 'Profile photo update processed';
      User? user;

      if (responseData.containsKey('user')) {
        try {
          user = User.fromJson(responseData['user']);
        } catch (e) {
          log("Error parsing user: $e");
        }
      }

      if (!success || response.statusCode != 200) {
        return ProfileResponse(
          success: false,
          message: message,
          user: user,
          errors:
              responseData['errors'] != null
                  ? Map<String, dynamic>.from(responseData['errors'])
                  : {'profile_photo': 'Failed to update profile photo'},
        );
      }

      return ProfileResponse(success: true, message: message, user: user);
    } catch (e) {
      log("Exception in updateProfilePhoto: $e");
      return ProfileResponse(
        success: false,
        message: 'Error updating profile photo: ${e.toString()}',
        errors: {'profile_photo': e.toString()},
      );
    }
  }


Future<bool> changePassword({
  required String currentPassword,
  required String newPassword,
}) async {
  try {
    final body = {
      'old_password': currentPassword,
      'new_password': newPassword,
      'new_password2': newPassword,
    };

    final response = await _apiService.post(
      ApiConstants.changePassword,
      body: body,
    );

    log("Change password response: ${response.statusCode}");
    log("Change password body: ${response.body}");

    if (response.statusCode == 200) {
      return true;
    } else {
      try {
        final errorData = json.decode(response.body);
        
        if (errorData['old_password'] != null) {
          throw Exception('Old password is not correct');
        } else if (errorData['new_password'] != null) {
          throw Exception('Invalid new password: ${errorData['new_password'][0]}');
        } else if (errorData['new_password2'] != null) {
          throw Exception('Password confirmation error: ${errorData['new_password2'][0]}');
        } else {
          throw Exception('Failed to change password');
        }
      } catch (e) {
        if (e.toString().contains('Exception:')) {
          rethrow; 
        }
        throw Exception('Failed to change password');
      }
    }
  } catch (e) {
    log("Exception in changePassword: $e");
    rethrow; 
  }
}
}

class ProfileException implements Exception {
  final String message;
  final Map<String, dynamic> errors;
  final User? user;

  ProfileException(this.message, this.errors, this.user);

  @override
  String toString() => message;
}
