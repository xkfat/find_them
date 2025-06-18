import 'dart:developer';

import 'package:find_them/data/services/api_service.dart';
import 'package:find_them/data/services/auth_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final AuthService _authService;

  AuthRepository(this._authService, {ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<dynamic> login(String username, String pwd) async {
    try {
      log("🔐 Repository: Attempting login for $username");
      final result = await _authService.login(username, pwd);
      log("✅ Repository: Login completed successfully");
      return result;
    } catch (e) {
      log("❌ Repository: Login failed - $e");
      rethrow;
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
      log("🔐 Repository: Attempting signup for $username");
      final result = await _authService.signup(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      log("✅ Repository: Signup completed successfully");
      return result;
    } catch (e) {
      log("❌ Repository: Signup failed - $e");
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    return await _apiService.hasToken();
  }

  Future<void> logout() async {
    try {
      log("🚪 Repository: Starting logout process");
      final success = await _authService.logout();
      if (!success) {
        throw Exception("Failed to logout from server");
      }
      log("✅ Repository: Logout completed successfully");
    } catch (e) {
      log("❌ Repository: Error logging out - $e");
      rethrow;
    }
  }

  Future<bool> deleteAccount(String username) async {
    try {
      log("🗑️ Repository: Attempting to delete account for $username");
      final response = await _authService.deleteAccount(username);
      if (response['success'] == true) {
        log("✅ Repository: Account deleted successfully");
        return true;
      }
      log("❌ Repository: Account deletion failed");
      return false;
    } catch (e) {
      log("❌ Repository: Error deleting account - $e");
      return false;
    }
  }
  // Add this method to your AuthRepository class:
 Future<dynamic> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    String? password,
  }) async {
    try {
      log("🔄 Repository: Attempting to update profile for: $username");
      
      final result = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      log("✅ Repository: Profile updated successfully for: $username");
      return result;
    } catch (e) {
      log("❌ Repository: Profile update failed for $username - $e");
      rethrow;
    }
  }

  Future<void> restoreNotificationService() async {
    try {
      log("🔄 Repository: Restoring notification service");
      await _authService.restoreNotificationToken();
      log("✅ Repository: Notification service restored");
    } catch (e) {
      log("❌ Repository: Error restoring notification service - $e");
    }
  }

  Future<String?> getFCMToken() async {
    return await _authService.getFCMToken();
  }

  Future<bool> hasValidFCMToken() async {
    return await _authService.hasValidFCMToken();
  }

  Future<void> syncFCMToken() async {
    await _authService.syncFCMToken();
  }
 
}