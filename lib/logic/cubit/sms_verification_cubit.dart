import 'package:bloc/bloc.dart';
import 'package:find_them/data/models/auth.dart';
import 'package:find_them/data/repositories/auth_repo.dart';
import 'package:equatable/equatable.dart';
part 'sms_verification_state.dart';

class SmsVerificationCubit extends Cubit<SmsVerificationState> {
  final AuthRepository _authRepository;

  SmsVerificationCubit(this._authRepository) : super(SmsVerificationInitial());

  Future<void> sendVerificationCode(String phoneNumber) async {
    emit(SmsVerificationLoading());

    try {
      await Future.delayed(const Duration(seconds: 1));

      emit(SmsVerificationCodeSent('Verification code sent to $phoneNumber'));
    } catch (e) {
      emit(SmsVerificationError('Failed to send verification code: $e'));
    }
  }

  Future<void> verifyCode(
    String enteredCode, {
    String correctCode = "1234",
  }) async {
    emit(SmsVerificationLoading());

    try {
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

  Future<void> completeSignupWithVerification(
    SignUpData signUpData,
    String enteredCode, {
    String correctCode = "1234",
  }) async {
    emit(SmsVerificationLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (enteredCode != correctCode) {
        emit(SmsVerificationError('Invalid verification code'));
        return;
      }


      await Future.delayed(const Duration(seconds: 1));

      emit(SmsVerificationSuccess());
    } catch (e) {
      emit(SmsVerificationError('Error completing signup: $e'));
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
      emit(SmsVerificationAccountDeletionError('Error: $e'));
    }
  }

  Future<void> resendCode(String phoneNumber) async {
    await sendVerificationCode(phoneNumber);
  }

  void reset() {
    emit(SmsVerificationInitial());
  }

  void handleTimeout() {
    emit(SmsVerificationTimedOut());
  }
}
