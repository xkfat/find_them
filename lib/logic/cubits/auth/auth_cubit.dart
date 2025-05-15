import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_them/core/constants/strings/string_constants.dart';
import 'package:find_them/data/models/auth.dart';
import 'package:find_them/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  static const String _welcomeShownKey = 'welcome_shown';

  AuthCubit(this._authService) : super(AuthInitial()) {
    checkAuth();
  }

  /// Check if the user is authenticated
  Future<void> checkAuth() async {
    emit(AuthLoading());
    try {
      print("Checking authentication status");
      final isAuthenticated = await _authService.isAuthenticated();

      if (isAuthenticated) {
        print("User is authenticated, getting auth data");
        final authData = await _authService.getAuthData();

        if (authData != null) {
          print("Authentication data loaded, user: ${authData.user.username}");
          emit(AuthAuthenticated(authData));
        } else {
          print("No authentication data found");
          emit(AuthUnauthenticated());
        }
      } else {
        print("User is not authenticated");
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print("Authentication check error: $e");
      emit(AuthUnauthenticated());
    }
  }

  /// Login with username and password
  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      print("Logging in with username: $username");
      final credentials = LoginCredentials(
        username: username,
        password: password,
      );

      final authData = await _authService.loginWithCredentials(credentials);
      print("Login successful for user: ${authData.user.username}");
      emit(AuthAuthenticated(authData));
    } catch (e) {
      print("Login error: $e");
      emit(AuthError(e.toString()));
    }
  }

  /// Register a new user (simplified for testing)
  Future<void> signup(SignUpData signupData) async {
    emit(AuthLoading());
    try {
      print("Signing up new user: ${signupData.username}");
      final authData = await _authService.signup(signupData);
      print("Signup successful");

      emit(
        AuthPhoneVerificationRequired(
          phoneNumber: signupData.phoneNumber,
          user: authData.user,
        ),
      );
      await sendVerificationSms(signupData.phoneNumber);
    } catch (e) {
      print("Signup error: $e");
      emit(AuthError(e.toString()));
    }
  }

  Future<void> sendVerificationSms(String phoneNumber) async {
    emit(AuthLoading());
    try {
      print("Skipping real SMS verification for testing");
      // Simply emit the code sent state with a fake verification ID
      await Future.delayed(
        const Duration(milliseconds: 300),
      ); // Just for UI feedback
      emit(
        AuthSmsCodeSent(
          verificationId: 'test-verification-id',
          phoneNumber: phoneNumber,
        ),
      );
    } catch (e) {
      print("SMS verification error: $e");
      emit(AuthError("SMS verification simulation failed"));
    }
  }

  /// Verify SMS code entered by user (simplified version)
  Future<void> verifySmsCode(String verificationId, String smsCode) async {
    emit(AuthLoading());
    try {
      print("Simulating successful SMS verification");
      // Just for UI feedback, add a small delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Get the current user from preferences if available
      final authData = await _authService.getAuthData();
      if (authData != null) {
        emit(AuthAuthenticated(authData));
      } else {
        // If no user is found, just redirect to home
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print("SMS verification error: $e");
      emit(AuthError("SMS verification failed"));
    }
  }

  /// Sign in with Facebook
  Future<void> signInWithFacebook() async {
    emit(AuthLoading());
    try {
      print("Starting Facebook sign-in");
      final authData = await _authService.signInWithFacebook();

      if (authData != null) {
        print("Facebook sign-in successful");
        emit(AuthAuthenticated(authData));
      } else {
        // User cancelled the Facebook Sign-in flow
        print("Facebook sign-in cancelled by user");
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print("Facebook sign-in error: $e");
      emit(AuthError("Facebook sign-in failed: ${e.toString()}"));
    }
  }

  /// Change user password
  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    emit(AuthLoading());
    try {
      print("Attempting to change password");
      if (newPassword != confirmPassword) {
        print("Password mismatch");
        emit(AuthError(StringConstants.passwordMismatch));
        return;
      }

      final success = await _authService.changePassword(
        oldPassword,
        newPassword,
        confirmPassword,
      );

      if (success) {
        print("Password changed successfully");
        final authData = await _authService.getAuthData();
        if (authData != null) {
          emit(AuthAuthenticated(authData));
        } else {
          print("Failed to retrieve authentication data after password change");
          emit(AuthError("Failed to retrieve authentication data"));
        }
      } else {
        print("Password change failed");
        emit(AuthError("Failed to change password"));
      }
    } catch (e) {
      print("Password change error: $e");
      emit(AuthError(e.toString()));
    }
  }

  /// Logout user
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      print("Logging out user");
      await _authService.logout();
      print("Logout successful");
      emit(AuthUnauthenticated());
    } catch (e) {
      // Even if logout fails, force unauthenticated state
      print("Logout error (forcing unauthenticated state): $e");
      emit(AuthUnauthenticated());
    }
  }

  /// Check if welcome screens have been shown
  Future<bool> hasShownWelcomeScreens() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_welcomeShownKey) ?? false;
  }

  /// Mark welcome screens as shown
  Future<void> setWelcomeScreensShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeShownKey, true);
  }
}
