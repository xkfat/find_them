// lib/logic/cubit/profile_cubit.dart
import 'dart:convert'; // Keep for error parsing
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
        _handleUpdateError(
          Exception('Cannot update profile: user data not loaded.'),
        );
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

      final updatedUser = await _profileRepository.updateProfilePartial(
        changedFields,
      );
      emit(ProfileUpdateSuccess(updatedUser));
      emit(
        ProfileLoaded(updatedUser),
      ); 
    } catch (e) {
      _handleUpdateError(e); 
    }
  }

  Future<void> uploadProfilePhoto(File photo) async {
    emit(ProfilePhotoUploading()); 
    try {
      final updatedUser = await _profileRepository.updateProfilePhoto(photo);
      emit(ProfilePhotoUploadSuccess(updatedUser));
      emit(
        ProfileLoaded(updatedUser),
      ); 
    } catch (e) {
      emit(
        ProfilePhotoUploadError(
          'Failed to upload profile photo: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(
      ProfileUpdating(),
    ); 
    try {
      final success = await _profileRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (success) {
        emit(const ProfilePasswordChangeSuccess());
        // loadProfile();
      } else {
        // If API returns 200 but indicates failure, or specific error code
        emit(
          const ProfilePasswordChangeError(
            'Failed to change password. Please check your current password.',
          ),
        );
      }
    } catch (e) {
      emit(
        ProfilePasswordChangeError('Error changing password: ${e.toString()}'),
      );
    }
  }

  void _handleUpdateError(dynamic e) {
    Map<String, String> fieldErrors = {};
    String errorMessage = 'Failed to update profile';

    try {
      if (e.toString().contains('{') && e.toString().contains('}')) {
        final start = e.toString().indexOf('{');
        final end = e.toString().lastIndexOf('}') + 1;
        final jsonStr = e.toString().substring(start, end);

        final Map<String, dynamic> errorData = json.decode(jsonStr);

        errorData.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            if (value.first.toString().toLowerCase().contains(
              'already exists',
            )) {
              fieldErrors[key] = '${key.replaceAll('_', ' ')} already exists!';
            } else {
              fieldErrors[key] = value.first.toString();
            }
          } else if (value is String) {
            if (value.toLowerCase().contains('already exists')) {
              fieldErrors[key] = '${key.replaceAll('_', ' ')} already exists!';
            } else {
              fieldErrors[key] = value;
            }
          }
        });

        if (errorData.containsKey('detail')) {
          errorMessage = errorData['detail'];
        }
      }
    } catch (_) {
      if (e.toString().toLowerCase().contains('username') &&
          e.toString().toLowerCase().contains('already exists')) {
        fieldErrors['username'] = 'Username already exists!';
      } else if (e.toString().toLowerCase().contains('email') &&
          e.toString().toLowerCase().contains('already exists')) {
        fieldErrors['email'] = 'Email already exists!';
      } else if (e.toString().toLowerCase().contains('phone_number') &&
          e.toString().toLowerCase().contains('already exists')) {
        fieldErrors['phone_number'] = 'Phone number already exists!';
      } else {
        errorMessage = e.toString();
      }
    }
    emit(ProfileUpdateError(errorMessage, fieldErrors));
  }
}
