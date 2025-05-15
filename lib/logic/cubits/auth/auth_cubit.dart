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
      final isAuthenticated = await _authService.isAuthenticated();
      if (isAuthenticated) {
        final authData = await _authService.getAuthData();
        if (authData != null) {
          emit(AuthAuthenticated(authData));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final credentials = LoginCredentials(
        username: username,
        password: password,
      );

      final authData = await _authService.loginWithCredentials(credentials);
      emit(AuthAuthenticated(authData));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Register a new user
  Future<void> signup(SignUpData signupData) async {
    emit(AuthLoading());
    try {
      // First create the user account in your backend
      final authData = await _authService.signup(signupData);

      // If phone verification is required
      if (signupData.phoneNumber.isNotEmpty) {
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
        emit(AuthAuthenticated(authData));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Send SMS verification code
  Future<void> sendVerificationSms(String phoneNumber) async {
    emit(AuthLoading());
    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          // Auto-verification completed (Android only)
          try {
            final userCredential = await firebase_auth.FirebaseAuth.instance
                .signInWithCredential(credential);

            final authData = await _authService.loginWithFirebaseCredential(
              userCredential,
            );
            if (authData != null) {
              emit(AuthAuthenticated(authData));
            } else {
              emit(AuthError("Failed to authenticate with auto-verification"));
            }
          } catch (e) {
            emit(AuthError(e.toString()));
          }
        },
        verificationFailed: (e) {
          emit(AuthError(e.message ?? 'Phone verification failed'));
        },
        codeSent: (verificationId, resendToken) {
          emit(
            AuthSmsCodeSent(
              verificationId: verificationId,
              phoneNumber: phoneNumber,
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {
          // Auto-retrieval timeout, can silently keep the verification ID
        },
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Verify SMS code entered by user
  Future<void> verifySmsCode(String verificationId, String smsCode) async {
    emit(AuthLoading());
    try {
      final authData = await _authService.verifySmsCode(
        verificationId,
        smsCode,
      );

      if (authData != null) {
        emit(AuthAuthenticated(authData));
      } else {
        emit(AuthError("SMS verification failed"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Resend verification SMS
  Future<void> resendVerificationSms(String phoneNumber) async {
    await sendVerificationSms(phoneNumber);
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      // This method returns UserCredential, not AuthData
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null) {
        // Now convert UserCredential to AuthData
        final authData = await _authService.loginWithFirebaseCredential(
          userCredential,
        );
        if (authData != null) {
          emit(AuthAuthenticated(authData));
        } else {
          emit(AuthError("Failed to authenticate with Google"));
        }
      } else {
        // User cancelled the Google Sign-in flow
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Sign in with Facebook
  Future<void> signInWithFacebook() async {
    emit(AuthLoading());
    try {
      final authData = await _authService.signInWithFacebook();

      if (authData != null) {
        emit(AuthAuthenticated(authData));
      } else {
        // User cancelled the Facebook Sign-in flow
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Sign in with Twitter
  Future<void> signInWithTwitter() async {
    emit(AuthLoading());
    try {
      final authData = await _authService.signInWithTwitter();

      if (authData != null) {
        emit(AuthAuthenticated(authData));
      } else {
        // User cancelled the Twitter Sign-in flow
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
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
      if (newPassword != confirmPassword) {
        emit(AuthError(StringConstants.passwordMismatch));
        return;
      }

      final success = await _authService.changePassword(
        oldPassword,
        newPassword,
        confirmPassword,
      );

      if (success) {
        final authData = await _authService.getAuthData();
        if (authData != null) {
          emit(AuthAuthenticated(authData));
        } else {
          emit(AuthError("Failed to retrieve authentication data"));
        }
      } else {
        emit(AuthError("Failed to change password"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Request password reset
  Future<void> requestPasswordReset(String email) async {
    emit(AuthLoading());
    try {
      final success = await _authService.sendPasswordResetEmail(email);

      if (success) {
        emit(AuthPasswordResetSent(email));
      } else {
        emit(AuthError("Failed to send password reset email"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Logout user
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authService.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      // Even if logout fails, force unauthenticated state
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
