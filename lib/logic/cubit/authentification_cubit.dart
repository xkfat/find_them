import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:find_them/data/repositories/auth_repo.dart';
import 'package:find_them/data/services/notification_service.dart';

part 'authentification_state.dart';

class AuthentificationCubit extends Cubit<AuthentificationState> {
  final AuthRepository _authRepository;
  final NotificationService _notificationService = NotificationService();

  AuthentificationCubit(this._authRepository)
    : super(AuthentificationInitial());

  Future<void> login(String username, String pwd) async {
    emit(AuthentificationLoading());
    try {
      log("🔐 Checking authentication status");

      var responseDta = await _authRepository.login(username, pwd);
      if (responseDta["code"] == "200") {
        log("✅ Login successful: ${responseDta["access"]}");

        emit(Authentificationloaded());
      } else if (responseDta["code"] == "401") {
        emit(Authentificationerreur(responseDta["msg"]));
      } else {
        emit(Authentificationerreur("Connect to server first"));
      }
    } catch (e) {
      log("❌ Login error: $e");
      emit(Authentificationerreur("Connect to server first"));
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