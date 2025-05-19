import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:find_them/data/repositories/auth_repo.dart';

part 'authentification_state.dart';

class AuthentificationCubit extends Cubit<AuthentificationState> {
  AuthRepository _authRepository;
  AuthentificationCubit(this._authRepository)
    : super(AuthentificationInitial());

  Future<void> login(String username, String Pwd) async {
    emit(AuthentificationLoading());
    try {
      print("Checking authentication status");

      var responseDta = await _authRepository.login(username, Pwd);
      if (responseDta["code"] == "200") {


 
        emit(Authentificationloaded());
      } else if (responseDta["code"] == "401") {
        emit(Authentificationerreur(responseDta["msg"]));
      } else {
        emit(Authentificationerreur("bbbvvbv"));
      }
    } catch (e) {
      emit(Authentificationerreur("bbbvvbv"));
    }
  }
}
