import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_them/core/constants/strings/string_constants.dart';
import 'package:find_them/data/models/auth.dart';
import 'package:find_them/data/repositories/auth_repo.dart';
import 'auth_state.dart';
/*
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  bool _testMode = false;

  void setTestMode(bool enabled) {
    _testMode = enabled;
    if (enabled) {
      emit(AuthUnauthenticated());
    }
  }

  AuthCubit(this._authRepository) : super(AuthInitial()) {}

  Future<void> checkAuth() async {
    if (_testMode) {
      emit(AuthUnauthenticated());
      return;
    }
    emit(AuthLoading());
    try {
      print("Checking authentication status");
      final isAuthenticated = await _authRepository.isAuthenticated();

      if (isAuthenticated) {
        print("User is authenticated, getting auth data");
        final authData = await _authRepository.getAuthData();

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

  // Modified method to handle two-step signup
  Future<void> initiateSignup(SignUpData signupData) async {
    emit(AuthLoading());
    try {
      print("Initiating signup process for: ${signupData.username}");

      // Instead of calling the API, we just validate and save the data temporarily
      // Here you could do local validation or even a preliminary API check

      // For now, just generate a verification code (in a real app, this would be sent via SMS)
      final verificationCode = "1234"; // Hardcoded for testing

      print("Verification code generated, sending to SMS verification screen");
      emit(
        AuthSmsVerificationRequired(
          signupData,
          verificationCode: verificationCode,
        ),
      );
    } catch (e) {
      print("Signup initiation error: $e");
      emit(AuthError(e.toString()));
    }
  }

  // New method to complete signup after SMS verification
  Future<void> completeSignup(SignUpData signupData, String enteredCode) async {
    emit(AuthLoading());
    try {
      print("Completing signup for user: ${signupData.username}");

      // In a real app, verify the entered code matches what was sent
      // For testing, we'll accept "1234"
      if (enteredCode != "1234") {
        emit(AuthError("Invalid verification code"));
        return;
      }

      // Now perform the actual signup API call
      final authData = await _authRepository.signup(signupData);
      print("Signup successful");
      emit(AuthAuthenticated(authData));
    } catch (e) {
      print("Signup completion error: $e");
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      print("Logging in with username: $username");
      final authData = await _authRepository.login(username, password);
      print("Login successful for user: ${authData.user.username}");
      emit(AuthAuthenticated(authData));
    } catch (e) {
      print("Login error: $e");
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signup(SignUpData signupData) async {
    emit(AuthLoading());
    try {
      print("Signing up new user: ${signupData.username}");
      final authData = await _authRepository.signup(signupData);
      print("Signup successful");
      emit(AuthSignupSuccessful(authData, signupData.phoneNumber));
    } catch (e) {
      print("Signup error: $e");
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthSocialAuthStarted('Google'));
    emit(AuthLoading());
    try {
      print("Starting Google sign-in flow");
      final authData = await _authRepository.signInWithGoogle();

      if (authData == null) {
        print("Google sign-in cancelled by user");
        emit(AuthUnauthenticated());
        return;
      }

      print("Google sign-in successful for user: ${authData.user.username}");
      emit(AuthAuthenticated(authData));
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
      final authData = await _authRepository.signInWithFacebook();

      if (authData == null) {
        print("Facebook sign-in cancelled or failed");
        emit(AuthError("Facebook sign-in was cancelled or failed"));
        return;
      }

      print("Facebook sign-in successful for user: ${authData.user.username}");
      emit(AuthAuthenticated(authData));
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

      final success = await _authRepository.changePassword(
        oldPassword,
        newPassword,
        confirmPassword,
      );

      if (success) {
        print("Password changed successfully");
        final authData = await _authRepository.getAuthData();
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

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      print("Logging out user");
      await _authRepository.logout();
      print("Logout successful");
      emit(AuthUnauthenticated());
    } catch (e) {
      print("Logout error (forcing unauthenticated state): $e");
      emit(AuthUnauthenticated());
    }
  }

  void resetSignupProcess() {
    emit(AuthUnauthenticated());
  }

  Future<void> validateSignupFields(SignUpData signupData) async {
    emit(AuthLoading());
    try {
      print("Validating signup fields for: ${signupData.username}");

      final result = await _authRepository.validateSignupFields(
        username: signupData.username,
        email: signupData.email,
        phoneNumber: signupData.phoneNumber,
      );

      if (result.containsKey('error') && result['error'] == true) {
        // Handle validation errors
        if (result.containsKey('data')) {
          final errorData = result['data'];
          print("Validation errors: $errorData");

          // Convert to the expected format
          Map<String, List<String>> errors = {};
          errorData.forEach((key, value) {
            if (value is List) {
              errors[key] = List<String>.from(value);
            } else if (value is String) {
              errors[key] = [value];
            }
          });

          emit(AuthValidationError(errors));
          return;
        }

        emit(AuthError(result['message'] ?? 'Validation failed'));
        return;
      }

      // If validation passes, proceed to SMS verification
      print("Field validation successful, sending to SMS verification screen");
      final verificationCode = "1234"; // Hardcoded for testing
      emit(
        AuthSmsVerificationRequired(
          signupData,
          verificationCode: verificationCode,
        ),
      );
    } catch (e) {
      print("Field validation error: $e");
      emit(AuthError(e.toString()));
    }
  }

}
*/