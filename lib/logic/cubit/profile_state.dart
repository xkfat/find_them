part of 'profile_cubit.dart'; 

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileLoadError extends ProfileState {
  final String message;

  const ProfileLoadError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdating extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final User user;

  const ProfileUpdateSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileUpdateError extends ProfileState {
  final String message;
  final Map<String, String> fieldErrors;
  final User? user; 

  const ProfileUpdateError(this.message, this.fieldErrors, this.user);

  @override
  List<Object?> get props => [message, fieldErrors, user];
}

class ProfilePhotoUploading extends ProfileState {}

class ProfilePhotoUploadSuccess extends ProfileState {
  final User user;

  const ProfilePhotoUploadSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfilePhotoUploadError extends ProfileState {
  final String message;
  final User? user; 

  const ProfilePhotoUploadError(this.message, this.user);

  @override
  List<Object?> get props => [message, user];
}

class ProfilePasswordChangeSuccess extends ProfileState {
  const ProfilePasswordChangeSuccess();
}

class ProfilePasswordChangeError extends ProfileState {
  final String message;

  const ProfilePasswordChangeError(this.message);

  @override
  List<Object?> get props => [message];
}