import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:find_them/core/constants/api_constants.dart';
import 'package:find_them/data/models/auth.dart';
import 'package:find_them/data/models/user.dart';
import 'package:find_them/data/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final ApiService _apiService;
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late Dio dio;
  static const String _authDataKey = 'auth_data';
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  AuthService(this._apiService) {
    dio = _apiService.dio;
  }

  /// Get authentication data from storage
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
      return null;
    }
  }

  /// Save authentication data to storage
  Future<void> _saveAuthData(AuthData authData) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = json.encode(authData.toJson());
    await prefs.setString(_authDataKey, encodedData);
    await _apiService.setAuthToken(authData.token);
  }

  /// Login with username and password
  Future<AuthData> loginWithCredentials(LoginCredentials credentials) async {
    try {
      Response response = await dio.post(
        ApiConstants.login,
        data: credentials.toJson(),
      );

      final authData = AuthData.fromJson(response.data);
      await _saveAuthData(authData);
      return authData;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Register a new user
  Future<AuthData> signup(SignUpData data) async {
    try {
      Response response = await dio.post(
        ApiConstants.signup,
        data: data.toJson(),
      );

      final authData = AuthData.fromJson(response.data);
      await _saveAuthData(authData);
      return authData;
    } catch (e) {
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final authData = await getAuthData();
    if (authData == null || authData.isExpired) {
      final refreshToken = authData?.refreshToken;
      if (refreshToken != null) {
        return await _refreshToken(refreshToken);
      }
      return false;
    }
    await _apiService.setAuthToken(authData.token);
    return true;
  }

  /// Refresh the authentication token
  Future<bool> _refreshToken(String refreshToken) async {
    try {
      Response response = await dio.post(
        ApiConstants.tokenRefresh,
        data: {'refresh': refreshToken},
      );

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
      return false;
    }
  }

  /// Get the current authenticated user
  Future<User?> getCurrentUser() async {
    final authData = await getAuthData();
    return authData?.user;
  }

  /// Change the user's password
  Future<bool> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      Response response = await dio.post(
        ApiConstants.changePassword,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password2': confirmPassword,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Logout the user
  Future<void> logout() async {
    try {
      // Attempt to logout from the API
      await dio.post(ApiConstants.logout);
    } catch (e) {
      // Log error but continue with local logout
    } finally {
      // Clear local auth data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authDataKey);
      await _apiService.clearAuthToken();

      // Sign out from Firebase
      try {
        await _googleSignIn.signOut();
        await FacebookAuth.instance.logOut();
        await _firebaseAuth.signOut();
      } catch (e) {
        // Ignore Firebase signout errors
      }
    }
  }

  /// Authenticate with Firebase and validate with backend
  Future<AuthData?> loginWithFirebaseCredential(
    firebase_auth.UserCredential credential,
  ) async {
    try {
      // Get the ID token from Firebase
      final idToken = await credential.user?.getIdToken();

      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      final response = await dio.post(
        ApiConstants
            .firebaseAuth, // Make sure to define this endpoint in your ApiConstants
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

      final authData = AuthData.fromJson(response.data);
      await _saveAuthData(authData);
      return authData;
    } catch (e) {
      throw Exception('Firebase authentication failed: ${e.toString()}');
    }
  }

  /// Phone authentication - verify phone number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(firebase_auth.PhoneAuthCredential) verificationCompleted,
    required Function(firebase_auth.FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  /// Phone authentication - verify SMS code
  Future<AuthData?> verifySmsCode(String verificationId, String smsCode) async {
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      return await loginWithFirebaseCredential(userCredential);
    } catch (e) {
      throw Exception('SMS verification failed: ${e.toString()}');
    }
  }

  Future<firebase_auth.UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google sign in error: $e');
      return null;
    }
  }

  /// Facebook Sign-in
  Future<AuthData?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) return null;

      final credential = firebase_auth.FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      return await loginWithFirebaseCredential(userCredential);
    } catch (e) {
      throw Exception('Facebook sign in failed: ${e.toString()}');
    }
  }

  /// Twitter Sign-in
  Future<AuthData?> signInWithTwitter() async {
    try {
      // You would need to replace this with a proper Twitter sign-in solution
      // since TwitterLogin was discontinued in favor of using the web flow
      // or newer packages

      // For example, you might use twitter_login package's newer version
      // or a web-based auth solution

      // After obtaining a Twitter auth credential:
      // final userCredential = await _firebaseAuth.signInWithCredential(credential);
      // return await loginWithFirebaseCredential(userCredential);

      throw Exception('Twitter login not implemented');
    } catch (e) {
      throw Exception('Twitter sign in failed: ${e.toString()}');
    }
  }

  /// Reset password
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      Response response = await dio.post(
        ApiConstants.changePassword,
        data: {'email': email},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
