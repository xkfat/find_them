import 'package:equatable/equatable.dart';
import 'package:find_them/data/models/auth.dart';
import 'package:find_them/data/models/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthData authData;

  const AuthAuthenticated(this.authData);

  @override
  List<Object?> get props => [authData];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthSocialAuthStarted extends AuthState {
  final String provider;

  const AuthSocialAuthStarted(this.provider);

  @override
  List<Object?> get props => [provider];
}

class AuthSignupSuccessful extends AuthState {
  final AuthData authData;
  final String phoneNumber;

  const AuthSignupSuccessful(this.authData, this.phoneNumber);

  @override
  List<Object?> get props => [authData, phoneNumber];
}

class AuthSmsVerificationRequired extends AuthState {
  final SignUpData signUpData;
  final String verificationCode;

  const AuthSmsVerificationRequired(
    this.signUpData, {
    this.verificationCode = '',
  });

  @override
  List<Object?> get props => [signUpData, verificationCode];
}

class AuthValidationError extends AuthState {
  final Map<String, List<String>> errors;

  const AuthValidationError(this.errors);

  @override
  List<Object?> get props => [errors];
}
