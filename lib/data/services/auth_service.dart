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

  AuthService(this._apiService) {
    dio = _apiService.dio;
  }

  static const _publicHeaders = {'Content-Type': 'application/json'};

  Future<Response<dynamic>> _postPublic(String url, Map<String, dynamic> data) {
    return dio.post(
      url,
      data: data,
      options: Options(headers: _publicHeaders), // <- wipes Authorization
    );
  }

  ///----- STORAGE METHODS -----///

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
      print('Error parsing auth data: $e');
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

  ///----- DJANGO DIRECT AUTH METHODS -----///

  /// Login with username and password directly to Django
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

  /// Register a new user directly with Django
  Future<AuthData> signup(SignUpData data) async {
    try {
      print('Attempting signup for user: ${data.username}');
      print('Request URL: ${dio.options.baseUrl}${ApiConstants.signup}');
      print('Request data: ${data.toJson()}');

      Response response = await dio.post(
        ApiConstants.signup,
        data: data.toJson(),
      );

      print('Signup successful, processing response');
      print('Response data: ${response.data}');

      final authData = AuthData.fromJson(response.data);
      await _saveAuthData(authData);
      return authData;
    } catch (e) {
      print('Signup error: $e');
      if (e is DioError && e.response != null) {
        print('Response status: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  /// Change the user's password
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

  ///----- FIREBASE SOCIAL/PHONE AUTH METHODS -----///

  /// Google Sign-in using Firebase
  Future<AuthData?> signInWithGoogle() async {
    try {
      print('Starting Google sign-in flow');
      // Step 1: Sign in with Google via Firebase
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google sign-in cancelled by user');
        return null; // User cancelled
      }

      print('Getting Google authentication');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in with Firebase using Google credentials');
      // Step 2: Get Firebase user credentials
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      print('Google sign-in successful, authenticating with backend');
      // Step 3: Exchange Firebase token for your app's token
      return await authenticateWithFirebase(userCredential);
    } catch (e) {
      print('Google sign-in error: $e');
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  /// Facebook Sign-in using Firebase
  Future<AuthData?> signInWithFacebook() async {
    try {
      print('Starting Facebook sign-in flow');
      // Step 1: Sign in with Facebook via Firebase
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) {
        print('Facebook sign-in cancelled or failed: ${result.status}');
        return null;
      }

      print('Creating Firebase credential from Facebook token');
      final credential = firebase_auth.FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );

      print('Signing in with Firebase using Facebook credentials');
      // Step 2: Get Firebase user credentials
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      print('Facebook sign-in successful, authenticating with backend');
      // Step 3: Exchange Firebase token for your app's token
      return await authenticateWithFirebase(userCredential);
    } catch (e) {
      print('Facebook sign-in error: $e');
      throw Exception('Facebook sign-in failed: ${e.toString()}');
    }
  }

  /// Phone authentication - verify phone number (SIMPLIFIED FOR TESTING)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(firebase_auth.PhoneAuthCredential) verificationCompleted,
    required Function(firebase_auth.FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    print('Simulating phone verification for test purposes: $phoneNumber');

    // Simulate code sent after a short delay
    await Future.delayed(const Duration(milliseconds: 500));
    codeSent('test-verification-id', 123456);
  }

  /// Phone verification - verify SMS code (SIMPLIFIED FOR TESTING)
  Future<AuthData?> verifySmsCode(String verificationId, String smsCode) async {
    try {
      print('Simulating SMS code verification for testing purposes');
      print('Using verification ID: $verificationId, code: $smsCode');

      // For testing, we'll just retrieve the current user's auth data if available
      final authData = await getAuthData();
      if (authData != null) {
        return authData;
      }

      // If no auth data exists, create a temporary mock AuthData
      // This is just for testing and should never be used in production
      return AuthData(
        token: 'test-token',
        refreshToken: 'test-refresh-token',
        user: User(
          id: 1,
          username: 'test_user',
          firstName: 'Test',
          lastName: 'User',
          email: 'test@example.com',
          phoneNumber: '+1234567890',
        ),
        expiryTime: DateTime.now().add(const Duration(hours: 1)),
      );
    } catch (e) {
      print('Simulated SMS verification error: $e');
      throw Exception('SMS verification simulation failed: ${e.toString()}');
    }
  }

  /// Helper method to exchange Firebase token for your app's token
  Future<AuthData?> authenticateWithFirebase(
    firebase_auth.UserCredential credential,
  ) async {
    try {
      print('Getting Firebase ID token');
      // Get the Firebase ID token
      final idToken = await credential.user?.getIdToken();

      if (idToken == null) {
        print('Failed to get Firebase ID token');
        throw Exception('Failed to get Firebase ID token');
      }

      print('Sending Firebase token to backend');
      // Send to your Django backend
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
      // Process Django response
      final authData = AuthData.fromJson(response.data);
      await _saveAuthData(authData);
      return authData;
    } catch (e) {
      print('Firebase authentication error with backend: $e');
      throw Exception('Firebase authentication failed: ${e.toString()}');
    }
  }

  ///----- AUTHENTICATION STATE METHODS -----///

  /// Check if user is authenticated
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

  /// Refresh the authentication token
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

  /// Get the current authenticated user
  Future<User?> getCurrentUser() async {
    try {
      final authData = await getAuthData();
      return authData?.user;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// Logout the user
  Future<void> logout() async {
    try {
      print('Logging out user');
      // Attempt to logout from the API
      await dio.post(ApiConstants.logout);
    } catch (e) {
      print('API logout error (continuing with local logout): $e');
    } finally {
      print('Clearing local auth data');
      // Clear local auth data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authDataKey);
      await _apiService.clearAuthToken();

      // Sign out from Firebase
      try {
        print('Signing out from Google');
        await _googleSignIn.signOut();
        print('Signing out from Facebook');
        await FacebookAuth.instance.logOut();
        print('Signing out from Firebase');
        await _firebaseAuth.signOut();
      } catch (e) {
        print('Firebase signout error (non-critical): $e');
      }

      print('Logout complete');
    }
  }
}
