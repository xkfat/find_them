import 'package:equatable/equatable.dart';
import 'package:find_them/data/models/auth.dart';
import 'package:find_them/data/models/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the app starts
class AuthInitial extends AuthState {}

/// Loading state during authentication operations
class AuthLoading extends AuthState {}

/// Authenticated state with auth data
class AuthAuthenticated extends AuthState {
  final AuthData authData;

  const AuthAuthenticated(this.authData);

  @override
  List<Object?> get props => [authData];
}

/// State when user is logged out
class AuthUnauthenticated extends AuthState {}

/// Error state with error message
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Phone verification required state
class AuthPhoneVerificationRequired extends AuthState {
  final String phoneNumber;
  final User user;

  const AuthPhoneVerificationRequired({
    required this.phoneNumber,
    required this.user,
  });

  @override
  List<Object?> get props => [phoneNumber, user];
}

/// SMS code sent state
class AuthSmsCodeSent extends AuthState {
  final String verificationId;
  final String phoneNumber;

  const AuthSmsCodeSent({
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [verificationId, phoneNumber];
}

/// Phone verification completed state
class AuthPhoneVerificationCompleted extends AuthState {
  final User user;

  const AuthPhoneVerificationCompleted(this.user);

  @override
  List<Object?> get props => [user];
}

/// Password reset sent state
class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent(this.email);

  @override
  List<Object?> get props => [email];
}

/// Password successfully reset state
class AuthPasswordResetSuccess extends AuthState {}