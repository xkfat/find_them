import 'dart:convert';
import 'dart:io';
import 'package:find_them/core/constants/api_constants.dart';
import 'package:find_them/data/models/user.dart';
import 'package:find_them/data/services/api_service.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  final ApiService _apiService;

  ProfileService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<User> getUserProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.profile);

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        return User.fromJson(userData);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

 

  Future<User> updateProfilePartial(Map<String, dynamic> fields) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.profile,
        body: fields,
      );

      if (response.statusCode == 200) {
        final updatedData = json.decode(response.body);
        return User.fromJson(updatedData);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Partial update failed');
      }
    } catch (e) {
      throw Exception('Error in partial profile update: $e');
    }
  }

  Future<User> updateProfilePhoto(File photo) async {
    try {
      final token = await _apiService.getAccessToken();

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

      if (response.statusCode == 200) {
        final updatedData = json.decode(response.body);
        return User.fromJson(updatedData);
      } else {
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            throw Exception(errorData);
          } catch (e) {
            throw Exception(
              'Error updating profile photo: ${response.statusCode}',
            );
          }
        } else {
          throw Exception(
            'Error updating profile photo: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      throw Exception('Error updating profile photo: $e');
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final body = {
        'current_password': currentPassword,
        'new_password': newPassword,
      };

      final response = await _apiService.post(
        ApiConstants.changePassword,
        body: body,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error changing password: $e');
    }
  }
}
