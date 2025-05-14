import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_them/core/constants/strings/string_constants.dart';
import 'package:find_them/data/models/auth.dart';
import 'package:find_them/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  static const String _authTokenKey = 'auth_token';
  static const String _welcomeShownKey = 'welcome_shown';

  AuthCubit(this._authService) : super(AuthInitial()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    emit(AuthLoading());
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      if (isAuthenticated) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          final authData = await _authService.getAuthData();
          if (authData != null) {
            emit(AuthAuthenticated(authData));
          } else {
            emit(AuthUnauthenticated());
          }
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
      
      final authData = await _authService.login(credentials);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_authTokenKey, authData.token);
      
      emit(AuthAuthenticated(authData));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signup(SignUpData signupData) async {
    emit(AuthLoading());
    try {
      final authData = await _authService.signup(signupData);
      
      // For development, simulate phone verification without Firebase
      emit(AuthPhoneVerificationRequired(
        phoneNumber: signupData.phoneNumber,
        user: authData.user,
      ));
      
      // Simulate a delay for SMS sending
      await Future.delayed(Duration(seconds: 1));
      
      // Emit SMS code sent with simulated verification ID
      emit(AuthSmsCodeSent(
        verificationId: 'simulated-verification-id',
        phoneNumber: signupData.phoneNumber,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> sendVerificationSms(String phoneNumber) async {
    emit(AuthLoading());
    try {
      // Simulate sending verification SMS
      await Future.delayed(Duration(seconds: 1));
      
      emit(AuthSmsCodeSent(
        verificationId: 'simulated-verification-id',
        phoneNumber: phoneNumber,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifySmsCode(String verificationId, String smsCode) async {
    emit(AuthLoading());
    try {
      // For development, accept any 6-digit code
      if (smsCode.length == 6) {
        // Simulate verification delay
        await Future.delayed(Duration(seconds: 1));
        
        // Get the current user
        final user = await _authService.getCurrentUser();
        
        if (user != null) {
          // Get auth data
          final authData = await _authService.getAuthData();
          if (authData != null) {
            emit(AuthAuthenticated(authData));
          } else {
            emit(AuthError("Authentication data not found"));
          }
        } else {
          emit(AuthError("User not found"));
        }
      } else {
        emit(AuthError("Invalid verification code. Please use a 6-digit code."));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resendVerificationSms(String phoneNumber) async {
    await sendVerificationSms(phoneNumber);
  }

  Future<void> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    emit(AuthLoading());
    try {
      if (newPassword != confirmPassword) {
        emit(AuthError(StringConstants.passwordMismatch));
        return;
      }
      
      final success = await _authService.changePassword(
        oldPassword, 
        newPassword, 
        confirmPassword
      );
      
      if (success) {
        final authData = await _authService.getAuthData();
        if (authData != null) {
          emit(AuthAuthenticated(authData));
        }
      } else {
        emit(AuthError("Failed to change password"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authService.logout();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authTokenKey);
      
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<bool> hasShownWelcomeScreens() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_welcomeShownKey) ?? false;
  }

  Future<void> setWelcomeScreensShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeShownKey, true);
  }

  
}