import 'dart:io';
import 'package:find_them/data/models/user.dart';
import 'package:find_them/data/services/profile_service.dart';

class ProfileRepository {
  final ProfileService _profileService;
  
  ProfileRepository({ProfileService? profileService}) 
      : _profileService = profileService ?? ProfileService();
  
  // Get current user profile
  Future<User> getUserProfile() async {
    try {
      return await _profileService.getUserProfile();
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }
  
  // Update user profile info
  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      return await _profileService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
  
  // Update profile photo
  Future<User> updateProfilePhoto(File photo) async {
    try {
      return await _profileService.updateProfilePhoto(photo);
    } catch (e) {
      throw Exception('Failed to update profile photo: $e');
    }
  }
  
  // Change password
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
}