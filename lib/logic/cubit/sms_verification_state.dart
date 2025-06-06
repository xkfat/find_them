part of 'sms_verification_cubit.dart';

sealed class SmsVerificationState extends Equatable {
  const SmsVerificationState();

  @override
  List<Object?> get props => [];
}

final class SmsVerificationInitial extends SmsVerificationState {}
class SmsVerificationLoading extends SmsVerificationState {}
class SmsVerificationCodeSent extends SmsVerificationState {
  final String message;
  
  const SmsVerificationCodeSent(this.message);
  
  @override
  List<Object?> get props => [message];
}
class SmsVerificationSuccess extends SmsVerificationState {}
class SmsVerificationError extends SmsVerificationState {
  final String error;
  
  const SmsVerificationError(this.error);
  
  @override
  List<Object?> get props => [error];
}
class SmsVerificationTimedOut extends SmsVerificationState {}
class SmsVerificationAccountDeletionLoading extends SmsVerificationState {}
class SmsVerificationAccountDeleted extends SmsVerificationState {}
class SmsVerificationAccountDeletionError extends SmsVerificationState {
  final String error;
  
  const SmsVerificationAccountDeletionError(this.error);
  
  @override
  List<Object?> get props => [error];
}
