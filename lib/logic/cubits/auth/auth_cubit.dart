import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_them/core/constants/strings/string_constants.dart';
import 'package:find_them/data/models/auth.dart';
import 'package:find_them/data/services/auth_service.dart';
import 'package:find_them/data/services/firebase_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final FirebaseAuthService _firebaseAuthService;

  static const String _welcomeShownKey = 'welcome_shown';

  AuthCubit(this._authService, this._firebaseAuthService)
    : super(AuthInitial()) {}

  /*  Future<void> checkAuth() async {
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

*/
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

  /// Register a new user
  Future<void> signup(SignUpData signupData) async {
    emit(AuthLoading());
    try {
      print("Signing up new user: ${signupData.username}");
      final authData = await _authService.signup(signupData);
      print("Signup successful");
      emit(AuthAuthenticated(authData));
    } catch (e) {
      print("Signup error: $e");
      emit(AuthError(e.toString()));
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    emit(AuthSocialAuthStarted('Google'));
    emit(AuthLoading());
    try {
      print("Starting Google sign-in flow");

      // 1. Use FirebaseAuthService to get Firebase credentials
      final userCredential = await _firebaseAuthService.signInWithGoogle();

      if (userCredential == null) {
        print("Google sign-in cancelled by user");
        emit(AuthUnauthenticated());
        return;
      }

      print("Google sign-in successful, authenticating with backend");

      // 2. Use AuthService to exchange Firebase token for your backend token
      final authData = await _authService.authenticateWithFirebase(
        userCredential,
      );

      if (authData != null) {
        print(
          "Backend authentication successful for user: ${authData.user.username}",
        );
        emit(AuthAuthenticated(authData));
      } else {
        print("Backend authentication failed");
        emit(AuthError("Failed to authenticate with the server"));
      }
    } catch (e) {
      print("Google sign-in error: $e");
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithFacebook() async {
    emit(AuthSocialAuthStarted('Facebook'));
    emit(AuthLoading());
    try {
      print("Starting Facebook sign-in flow");

      // 1. Use FirebaseAuthService to get Firebase credentials
      final userCredential = await _firebaseAuthService.signInWithFacebook();

      if (userCredential == null) {
        print("Facebook sign-in cancelled or failed");
        emit(AuthError("Facebook sign-in was cancelled or failed"));
        return;
      }

      print("Facebook sign-in successful, authenticating with backend");

      try {
        // 2. Use AuthService to exchange Firebase token for your backend token
        final authData = await _authService.authenticateWithFirebase(
          userCredential,
        );

        if (authData != null) {
          print(
            "Backend authentication successful for user: ${authData.user.username}",
          );
          emit(AuthAuthenticated(authData));
        } else {
          print("Backend authentication failed");
          emit(AuthError("Failed to authenticate with the server"));
        }
      } catch (e) {
        print("Error authenticating with backend: $e");
        emit(AuthError("Error connecting to server: ${e.toString()}"));
      }
    } catch (e) {
      print("Facebook sign-in error: $e");
      emit(AuthError("Facebook sign-in error: ${e.toString()}"));
    }
  }

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

      // Sign out from Firebase first
      try {
        await _firebaseAuthService.signOut();
      } catch (e) {
        print("Firebase signout error (non-critical): $e");
      }

      // Then log out from the backend
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
