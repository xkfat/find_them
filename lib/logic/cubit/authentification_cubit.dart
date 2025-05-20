import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:find_them/data/repositories/auth_repo.dart';

part 'authentification_state.dart';

class AuthentificationCubit extends Cubit<AuthentificationState> {
  final AuthRepository _authRepository;
  AuthentificationCubit(this._authRepository)
    : super(AuthentificationInitial());

  Future<void> login(String username, String pwd) async {
    emit(AuthentificationLoading());
    try {
      log("Checking authentication status");

      var responseDta = await _authRepository.login(username, pwd);
      if (responseDta["code"] == "200") {
        log(responseDta["access"]);
        
        emit(Authentificationloaded());
      } else if (responseDta["code"] == "401") {
        emit(Authentificationerreur(responseDta["msg"]));
      } else {
        emit(Authentificationerreur("Connect to server first"));
      }
    } catch (e) {
      emit(Authentificationerreur("Connect to server first"));
    }
  }
}
