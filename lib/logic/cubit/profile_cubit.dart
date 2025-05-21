import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:find_them/data/models/user.dart';
import 'package:find_them/data/repositories/profile_repo.dart';

part 'profile_state.dart'; 

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit(this._profileRepository) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final user = await _profileRepository.getUserProfile();
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileLoadError('Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? phoneNumber,
  }) async {
    emit(ProfileUpdating()); 
    try {
      User? currentUser;
      if (state is ProfileLoaded) {
        currentUser = (state as ProfileLoaded).user;
      } else {
        await loadProfile();
        if (state is ProfileLoaded) {
          currentUser = (state as ProfileLoaded).user;
        }
      }

      if (currentUser == null) {
        emit(ProfileUpdateError(
          'Cannot update profile: user data not loaded.', 
          {}, 
          null
        ));
        return;
      }

      Map<String, dynamic> changedFields = {};
      if (firstName != null && firstName != currentUser.firstName) {
        changedFields['first_name'] = firstName;
      }
      if (lastName != null && lastName != currentUser.lastName) {
        changedFields['last_name'] = lastName;
      }
      if (username != null && username != currentUser.username) {
        changedFields['username'] = username;
      }
      if (email != null && email != currentUser.email) {
        changedFields['email'] = email;
      }
      if (phoneNumber != null && phoneNumber != currentUser.phoneNumber) {
        changedFields['phone_number'] = phoneNumber;
      }

      if (changedFields.isEmpty) {
        emit(ProfileLoaded(currentUser));
        return;
      }

      final response = await _profileRepository.updateProfilePartial(changedFields);
      
      if (response.success && response.user != null) {
        emit(ProfileUpdateSuccess(response.user!));
        emit(ProfileLoaded(response.user!));
      } else {
        Map<String, String> fieldErrors = {};
        if (response.errors != null) {
          response.errors!.forEach((key, value) {
            fieldErrors[key] = value.toString();
          });
        }
        
        emit(ProfileUpdateError(
          response.message, 
          fieldErrors, 
          response.user ?? currentUser
        ));
      }
    } catch (e) {
      User? currentUser;
      if (state is ProfileLoaded) {
        currentUser = (state as ProfileLoaded).user;
      }
      
      emit(ProfileUpdateError(
        'An unexpected error occurred: ${e.toString()}', 
        {}, 
        currentUser
      ));
    }
  }

  Future<void> uploadProfilePhoto(File photo) async {
    emit(ProfilePhotoUploading()); 
    try {
      User? currentUser;
      if (state is ProfileLoaded) {
        currentUser = (state as ProfileLoaded).user;
      }
      
      final response = await _profileRepository.updateProfilePhoto(photo);
      
      if (response.success && response.user != null) {
        emit(ProfilePhotoUploadSuccess(response.user!));
        emit(ProfileLoaded(response.user!));
      } else {
        emit(ProfilePhotoUploadError(
          response.message,
          response.user ?? currentUser
        ));
      }
    } catch (e) {
      User? currentUser;
      if (state is ProfileLoaded) {
        currentUser = (state as ProfileLoaded).user;
      }
      
      emit(ProfilePhotoUploadError(
        'Failed to upload profile photo: ${e.toString()}',
        currentUser
      ));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(ProfileUpdating()); 
    try {
      final success = await _profileRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (success) {
        emit(const ProfilePasswordChangeSuccess());
        loadProfile();
      } else {
        emit(const ProfilePasswordChangeError(
          'Failed to change password. Please check your current password.'
        ));
      }
    } catch (e) {
      emit(ProfilePasswordChangeError(
        'Error changing password: ${e.toString()}'
      ));
    }
  }
}