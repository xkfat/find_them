import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:find_them/data/repositories/auth_repo.dart';
import 'package:find_them/data/services/notification_service.dart';
import 'package:find_them/data/services/prefrences_service.dart';

part 'authentification_state.dart';

class AuthentificationCubit extends Cubit<AuthentificationState> {
  final AuthRepository _authRepository;
  final NotificationService _notificationService = NotificationService();
    final ProfilePreferencesService _preferencesService = ProfilePreferencesService();


  AuthentificationCubit(this._authRepository)
    : super(AuthentificationInitial());
  Future<void> login(String username, String password) async {
    emit(AuthentificationLoading());
    
    try {
      var responseData = await _authRepository.login(username, password);
      
      if (responseData != null) {
        emit(Authentificationloaded());
        
        await _preferencesService.clearCachedPreferences();
        await _syncPreferencesAfterLogin();
      } else {
        emit(Authentificationerreur("Login failed"));
      }
    } catch (e) {
      emit(Authentificationerreur("Login error: $e"));
    }
  }

  // Sync preferences after login
  Future<void> _syncPreferencesAfterLogin() async {
    try {
      // Load user preferences from server
      final serverPrefs = await _preferencesService.loadPreferences();
      
      // Notify main app to update UI with server preferences
      // You can use a global event bus or callback for this
      
      log('✅ Preferences synced after login: $serverPrefs');
    } catch (e) {
      log('❌ Failed to sync preferences after login: $e');
    }
  }


  Future<void> checkAuthStatus() async {
    emit(AuthentificationLoading());
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        log("🔄 User already logged in, restoring session...");
        
        await _authRepository.restoreNotificationService();
        
        emit(Authentificationloaded());
      } else {
        emit(AuthentificationInitial());
      }
    } catch (e) {
      log("❌ Error checking auth status: $e");
      emit(AuthentificationInitial());
    }
  }

  Future<void> logout() async {
    emit(AuthentificationLoading());
    try {
      log("🚪 Logging out user...");
      
      await _authRepository.logout();
      
      emit(AuthentificationInitial());
      log("✅ Logout completed successfully");
    } catch (e) {
      log("❌ Error logging out: $e");
      emit(Authentificationerreur("Error logging out"));
    }
  }
}