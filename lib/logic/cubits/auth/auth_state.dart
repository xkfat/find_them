import 'package:equatable/equatable.dart';
import 'find_them/data/models/user.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final String token;
  
  AuthAuthenticated({required this.user, required this.token});
  
  @override
  List<Object?> get props => [user, token];
}

class AuthError extends AuthState {
  final String message;
  
  AuthError({required this.message});
  
  @override
  List<Object?> get props => [message];
}