part of 'social_auth_cubit.dart';

abstract class SocialAuthState {}

class SocialAuthInitial extends SocialAuthState {}

class SocialAuthLoading extends SocialAuthState {}

class SocialAuthSuccess extends SocialAuthState {
  final Map<String, dynamic> userData;

  SocialAuthSuccess(this.userData);
}

class SocialAuthError extends SocialAuthState {
  final String message;

  SocialAuthError(this.message);
}