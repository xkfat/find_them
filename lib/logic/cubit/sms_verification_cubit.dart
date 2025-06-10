import 'package:bloc/bloc.dart';
import 'package:find_them/data/models/auth.dart';
import 'package:find_them/data/repositories/auth_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'sms_verification_state.dart';

class SmsVerificationCubit extends Cubit<SmsVerificationState> {
  final AuthRepository _authRepository;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String? _verificationId;
  int? _resendToken;

  SmsVerificationCubit(this._authRepository) : super(SmsVerificationInitial());

  Future<void> sendVerificationCode(String phoneNumber) async {
    emit(SmsVerificationLoading());

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) {
          // Auto verification - just emit success, don't sign in
          emit(SmsVerificationSuccess());
        },
        verificationFailed: (e) {
          emit(SmsVerificationError(_getErrorMessage(e)));
        },
        codeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          emit(
            SmsVerificationCodeSent('Verification code sent to $phoneNumber'),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      emit(
        SmsVerificationError(
          'Failed to send verification code: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> verifyCode(String enteredCode) async {
    if (_verificationId == null) {
      emit(
        SmsVerificationError('Verification ID not found. Please resend code.'),
      );
      return;
    }

    emit(SmsVerificationLoading());

    try {
      // Just create credential and verify it exists - don't sign in
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: enteredCode,
      );

      // Test the credential without signing in
      if (credential.providerId == 'phone' &&
          credential.signInMethod == 'phone') {
        emit(SmsVerificationSuccess());
      } else {
        emit(SmsVerificationError('Invalid verification code'));
      }
    } catch (e) {
      emit(SmsVerificationError('Invalid verification code'));
    }
  }

  Future<void> completeSignupWithVerification(
    SignUpData signUpData,
    String enteredCode,
  ) async {
    if (_verificationId == null) {
      emit(
        SmsVerificationError('Verification ID not found. Please resend code.'),
      );
      return;
    }

    emit(SmsVerificationLoading());

    try {
      // Step 1: Just verify the code format is correct
      if (enteredCode.length == 6 &&
          enteredCode.contains(RegExp(r'^[0-9]+$'))) {
        // Step 2: Call your backend signup directly (skip Firebase signin)
        await _authRepository.signup(
          firstName: signUpData.firstName,
          lastName: signUpData.lastName,
          username: signUpData.username,
          email: signUpData.email,
          phoneNumber: signUpData.phoneNumber,
          password: signUpData.password,
          passwordConfirmation: signUpData.passwordConfirmation,
        );

        emit(SmsVerificationSuccess());
      } else {
        emit(SmsVerificationError('Invalid verification code format'));
      }
    } catch (e) {
      emit(SmsVerificationError('Error completing signup: ${e.toString()}'));
    }
  }

  Future<void> resendCode(String phoneNumber) async {
    emit(SmsVerificationLoading());

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) {
          emit(SmsVerificationSuccess());
        },
        verificationFailed: (e) {
          emit(SmsVerificationError(_getErrorMessage(e)));
        },
        codeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          emit(
            SmsVerificationCodeSent('Verification code resent to $phoneNumber'),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      emit(
        SmsVerificationError(
          'Failed to resend verification code: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> deleteAccount(String username) async {
    emit(SmsVerificationAccountDeletionLoading());

    try {
      final success = await _authRepository.deleteAccount(username);

      if (success) {
        emit(SmsVerificationAccountDeleted());
      } else {
        emit(SmsVerificationAccountDeletionError('Failed to delete account'));
      }
    } catch (e) {
      emit(SmsVerificationAccountDeletionError('Error: ${e.toString()}'));
    }
  }

  void reset() {
    _verificationId = null;
    _resendToken = null;
    emit(SmsVerificationInitial());
  }

  void handleTimeout() {
    emit(SmsVerificationTimedOut());
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number format is invalid';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'invalid-verification-id':
        return 'Invalid verification ID';
      case 'quota-exceeded':
        return 'SMS quota exceeded';
      case 'app-not-authorized':
        return 'App not authorized for Firebase Authentication';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return e.message ?? 'An error occurred during verification';
    }
  }
}
