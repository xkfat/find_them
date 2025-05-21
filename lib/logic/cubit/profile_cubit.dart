import 'dart:convert';
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
      emit(ProfileError('Failed to load profile: ${e.toString()}'));
    }
  }
  
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    File? profilePhoto,
  }) async {
    emit(ProfileUpdating());
    
    try {
      User updatedUser = await _profileRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
      );
      
      if (profilePhoto != null) {
        updatedUser = await _profileRepository.updateProfilePhoto(profilePhoto);
      }
      
      emit(ProfileUpdateSuccess(updatedUser));
    } catch (e) {
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
              fieldErrors[key] = value.first.toString();
            } else if (value is String) {
              fieldErrors[key] = value;
            }
          });
          
          if (errorData.containsKey('detail')) {
            errorMessage = errorData['detail'];
          }
        }
      } catch (_) {
        errorMessage = e.toString();
      }
      
      emit(ProfileUpdateError(errorMessage, fieldErrors));
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
        emit(PasswordChangeSuccess());
      } else {
        emit(ProfileError('Failed to change password'));
      }
    } catch (e) {
      emit(ProfileError('Failed to change password: ${e.toString()}'));
    }
  }
}