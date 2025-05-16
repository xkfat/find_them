import 'package:bloc/bloc.dart';
import 'package:find_them/data/models/auth.dart';
import 'package:find_them/data/repositories/auth_repo.dart';
import 'package:equatable/equatable.dart';
part 'sms_verification_state.dart';

class SmsVerificationCubit extends Cubit<SmsVerificationState> {
  final AuthRepository _authRepository;

  SmsVerificationCubit(this._authRepository) : super(SmsVerificationInitial());

  // Mock sending a verification code
  Future<void> sendVerificationCode(String phoneNumber) async {
    emit(SmsVerificationLoading());

    try {
      // In a real app, this would call an API to send an SMS
      // For a mock implementation, just simulate a delay
      await Future.delayed(const Duration(seconds: 1));

      // Emit success state
      emit(SmsVerificationCodeSent('Verification code sent to $phoneNumber'));
    } catch (e) {
      emit(SmsVerificationError('Failed to send verification code: $e'));
    }
  }

  // Verify the entered code
  Future<void> verifyCode(
    String enteredCode, {
    String correctCode = "1234",
  }) async {
    emit(SmsVerificationLoading());

    try {
      // In a real app, this would validate with a backend
      // For a mock implementation, just check against the hardcoded value
      await Future.delayed(const Duration(milliseconds: 500));

      if (enteredCode == correctCode) {
        emit(SmsVerificationSuccess());
      } else {
        emit(SmsVerificationError('Invalid verification code'));
      }
    } catch (e) {
      emit(SmsVerificationError('Error verifying code: $e'));
    }
  }

  // Complete signup with verification
  Future<void> completeSignupWithVerification(
    SignUpData signUpData,
    String enteredCode, {
    String correctCode = "1234",
  }) async {
    emit(SmsVerificationLoading());

    try {
      // First verify the code
      await Future.delayed(const Duration(milliseconds: 500));

      if (enteredCode != correctCode) {
        emit(SmsVerificationError('Invalid verification code'));
        return;
      }

      // In a real app, you would call your backend to complete the signup
      // This is where you would transition from a pending user to an active user

      // For a mock implementation, just simulate success
      await Future.delayed(const Duration(seconds: 1));

      emit(SmsVerificationSuccess());
    } catch (e) {
      emit(SmsVerificationError('Error completing signup: $e'));
    }
  }

  // For handling going back and deleting the account
  Future<void> deleteAccount(String username) async {
    emit(SmsVerificationAccountDeletionLoading());

    try {
      // Call repository to delete the account
      final success = await _authRepository.deleteAccount(username);

      if (success) {
        emit(SmsVerificationAccountDeleted());
      } else {
        emit(SmsVerificationAccountDeletionError('Failed to delete account'));
      }
    } catch (e) {
      emit(SmsVerificationAccountDeletionError('Error: $e'));
    }
  }

  // Resend verification code
  Future<void> resendCode(String phoneNumber) async {
    await sendVerificationCode(phoneNumber);
  }

  // Reset to initial state
  void reset() {
    emit(SmsVerificationInitial());
  }

  // Handle timeout
  void handleTimeout() {
    emit(SmsVerificationTimedOut());
  }
}
