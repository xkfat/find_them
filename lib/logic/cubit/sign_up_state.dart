part of 'sign_up_cubit.dart';

sealed class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object> get props => [];
}

final class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUploaded extends SignUpState {}

class SignUperreur extends SignUpState {
   String msg;
   SignUperreur(this.msg);
   
}

class SignUpFieldError extends SignUpState {
  final String field;
  final String message;

  const SignUpFieldError({required this.field, required this.message});
}