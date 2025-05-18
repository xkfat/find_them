import 'package:dio/dio.dart';
import 'package:find_them/data/models/auth.dart';
import 'package:find_them/data/models/user.dart';
import 'package:find_them/data/services/auth_service.dart';
import 'package:find_them/data/services/social_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/widgets.dart';

class AuthRepository {
  final AuthService _authService;
  // final FirebaseAuthService _firebaseAuthService;

  AuthRepository(this._authService);

  Future<dynamic> login(String username, String Pwd) async {
    return await _authService.login(username, Pwd);
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
    return await _authService.signup(
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }






  Future<bool> deleteAccount(String username) async {
  try {
    final response = await _authService.deleteAccount(username);
    return response['success'] == true;
  } catch (e) {
    print("Error deleting account: $e");
    return false;
  }
}

  /*

  Future<User?> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }

  Future<AuthData?> getAuthData() async {
    return await _authService.getAuthData();
  }

  Future<AuthData> login(String username, String password) async {
    final credentials = LoginCredentials(
      username: username,
      password: password,
    );
    return await _authService.loginWithCredentials(credentials);
  }

  Future<AuthData> signup(SignUpData signupData) async {
    return await _authService.signup(signupData);
  }

  Future<AuthData?> signInWithGoogle() async {
    final userCredential = await _firebaseAuthService.signInWithGoogle();
    if (userCredential == null) {
      return null;
    }
    return await _authService.authenticateWithFirebase(userCredential);
  }

  Future<AuthData?> signInWithFacebook() async {
    final userCredential = await _firebaseAuthService.signInWithFacebook();
    if (userCredential == null) {
      return null;
    }
    return await _authService.authenticateWithFirebase(userCredential);
  }

  Future<bool> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    return await _authService.changePassword(
      oldPassword,
      newPassword,
      confirmPassword,
    );
  }

  Future<void> logout() async {
    await _firebaseAuthService.signOut();
    await _authService.logout();
  }

  Future<Map<String, dynamic>> validateSignupFields({
    required String username,
    required String email,
    String? phoneNumber,
  }) async {
    try {
      await _authService.validateSignupFields(
        username: username,
        email: email,
        phoneNumber: phoneNumber,
      );
      return {'success': true};
    } catch (e) {
      if (e is DioException && e.response != null) {
        return {'error': true, 'data': e.response?.data};
      }
      return {'error': true, 'message': e.toString()};
    }
  }
}
*/
}
