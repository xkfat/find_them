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

  /// Register a new user
  Future<void> signup(SignUpData signupData) async {
    emit(AuthLoading());
    try {
      print("Signing up new user: ${signupData.username}");
      // First create the user account in your backend
      final authData = await _authService.signup(signupData);
      print("Signup successful");

      // If phone verification is required
      if (signupData.phoneNumber.isNotEmpty) {
        print("Phone verification required for: ${signupData.phoneNumber}");
        emit(
          AuthPhoneVerificationRequired(
            phoneNumber: signupData.phoneNumber,
            user: authData.user,
          ),
        );

        // Automatically initiate phone verification
        await sendVerificationSms(signupData.phoneNumber);
      } else {
        // No phone verification needed
        print("No phone verification needed");
        emit(AuthAuthenticated(authData));
      }
    } catch (e) {
      print("Signup error: $e");
      emit(AuthError(e.toString()));
    }
  }

  /// Send SMS verification code
  Future<void> sendVerificationSms(String phoneNumber) async {
    emit(AuthLoading());
    try {
      print("Sending verification SMS to: $phoneNumber");
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          // Auto-verification completed (Android only)
          print("Phone verification automatically completed");
          try {
            print("Signing in with auto-verification credential");
            final userCredential = await firebase_auth.FirebaseAuth.instance
                .signInWithCredential(credential);

            print("Getting auth data from backend");
            final authData = await _authService.authenticateWithFirebase(
              userCredential,
            );
            
            if (authData != null) {
              print("Authentication successful");
              emit(AuthAuthenticated(authData));
            } else {
              print("Authentication failed after auto-verification");
              emit(AuthError("Failed to authenticate with auto-verification"));
            }
          } catch (e) {
            print("Auto-verification error: $e");
            emit(AuthError(e.toString()));
          }
        },
        verificationFailed: (e) {
          print("Phone verification failed: ${e.message}");
          emit(AuthError(e.message ?? 'Phone verification failed'));
        },
        codeSent: (verificationId, resendToken) {
          print("SMS code sent, verification ID: $verificationId");
          emit(
            AuthSmsCodeSent(
              verificationId: verificationId,
              phoneNumber: phoneNumber,
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {
          // Auto-retrieval timeout, can silently keep the verification ID
          print("SMS code auto retrieval timeout");
        },
      );
    } catch (e) {
      print("SMS verification send error: $e");
      emit(AuthError(e.toString()));
    }
  }

  /// Verify SMS code entered by user
  Future<void> verifySmsCode(String verificationId, String smsCode) async {
    emit(AuthLoading());
    try {
      print("Verifying SMS code for ID: $verificationId");
      final authData = await _authService.verifySmsCode(
        verificationId,
        smsCode,
      );

      if (authData != null) {
        print("SMS verification successful");
        emit(AuthAuthenticated(authData));
      } else {
        print("SMS verification resulted in no auth data");
        emit(AuthError("SMS verification failed"));
      }
    } catch (e) {
      print("SMS verification error: $e");
      emit(AuthError(e.toString()));
    }
  }

  /// Resend verification SMS
  Future<void> resendVerificationSms(String phoneNumber) async {
    print("Resending verification SMS to: $phoneNumber");
    await sendVerificationSms(phoneNumber);
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      print("Starting Google sign-in");
      final authData = await _authService.signInWithGoogle();

      if (authData != null) {
        print("Google sign-in successful");
        emit(AuthAuthenticated(authData));
      } else {
        // User cancelled the Google Sign-in flow
        print("Google sign-in cancelled by user");
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print("Google sign-in error: $e");
      emit(AuthError("Google sign-in failed: ${e.toString()}"));
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