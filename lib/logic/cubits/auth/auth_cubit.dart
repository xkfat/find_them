import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_them/data/repositories/user_repo.dart';
import 'package:find_them/data/models/user.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final token = await authRepository.getStoredToken();
      if (token != null) {
        final user = await authRepository.getCurrentUser();
        emit(AuthAuthenticated(user: user, token: token));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthError(message: "Session expired, please login again"));
    }
  }

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final result = await authRepository.login(username, password);
      await authRepository.storeToken(result.token);
      emit(AuthAuthenticated(user: result.user, token: result.token));
    } catch (e) {
      emit(AuthError(message: "Login failed: ${e.toString()}"));
    }
  }

  Future<void> register(
    String username,
    String email,
    String password,
    String firstName,
    String lastName,
    String phoneNumber,
  ) async {
    emit(AuthLoading());
    try {
      final result = await authRepository.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );
      await authRepository.storeToken(result.token);
      emit(AuthAuthenticated(user: result.user, token: result.token));
    } catch (e) {
      emit(AuthError(message: "Registration failed: ${e.toString()}"));
    }
  }

  Future<void> logout() async {
    await authRepository.clearToken();
    emit(AuthInitial());
  }
}
