import 'dart:io';
import 'package:find_them/data/models/user.dart';
import 'package:find_them/data/services/profile_service.dart';

class ProfileRepository {
  final ProfileService _profileService;
  
  ProfileRepository({ProfileService? profileService}) 
      : _profileService = profileService ?? ProfileService();
  
  Future<User> getUserProfile() async {
    try {
      return await _profileService.getUserProfile();
    } catch (e) {
      if (e is ProfileException) {
        if (e.user != null) {
          return e.user!;
        }
      }
      throw Exception('Failed to get user profile: $e');
    }
  }
  
  Future<ProfileResponse> updateProfilePhoto(File photo) async {
    try {
      return await _profileService.updateProfilePhoto(photo);
    } catch (e) {
      return ProfileResponse(
        success: false,
        message: e.toString(),
        errors: {'general': 'Failed to update profile photo: $e'},
      );
    }
  }

  Future<ProfileResponse> updateProfilePartial(Map<String, dynamic> fields) async {
    try {
      return await _profileService.updateProfilePartial(fields);
    } catch (e) {
      return ProfileResponse(
        success: false,
        message: e.toString(),
        errors: {'general': 'Failed to update profile: $e'},
      );
    }
  }
  
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      return await _profileService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
  
  User? getUserFromException(dynamic e) {
    if (e is ProfileException && e.user != null) {
      return e.user;
    }
    return null;
  }
}