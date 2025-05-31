import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:find_them/data/repositories/social_auth_repo.dart';

part 'social_auth_state.dart';

class SocialAuthCubit extends Cubit<SocialAuthState> {
  final SocialAuthRepository _repository;
  bool _isClosed = false;

  SocialAuthCubit(this._repository) : super(SocialAuthInitial());

  Future<void> signInWithGoogle() async {
    if (_isClosed) return;

    log("🔵 Google Sign In: Starting in cubit...");
    emit(SocialAuthLoading());

    try {
      final result = await _repository.signInWithGoogle();
      log("🔵 Google Sign In: Repository result received");
      log("🔵 Google Sign In: Success = ${result['success']}");
      log("🔵 Google Sign In: Full result = $result");

      if (_isClosed) {
        log("❌ Google Sign In: Cubit is closed, aborting");
        return;
      }

      if (result['success'] == true) {
        log("✅ Google Sign In: SUCCESS CONDITION MET!");
        log("✅ Google Sign In: About to emit SocialAuthSuccess");
        log("✅ Google Sign In: User data = ${result['user']}");

        emit(SocialAuthSuccess(result['user']));

        log("✅ Google Sign In: SocialAuthSuccess has been emitted!");
        log("✅ Google Sign In: Current state is: ${state.runtimeType}");

        if (state is SocialAuthSuccess) {
          log("✅ Google Sign In: CONFIRMED - State is SocialAuthSuccess");
        } else {
          log(
            "❌ Google Sign In: ERROR - State is ${state.runtimeType}, not SocialAuthSuccess",
          );
        }
      } else {
        log("❌ Google Sign In: Success condition not met");
        log("❌ Google Sign In: result['success'] = ${result['success']}");
        log("❌ Google Sign In: message = ${result['message']}");
        emit(SocialAuthError(result['message'] ?? 'Google Sign-In failed'));
      }
    } catch (e, stackTrace) {
      log('❌ Google Sign In Error: $e');
      log('❌ Google Sign In Stack: $stackTrace');
      if (!_isClosed) {
        emit(SocialAuthError('Google Sign-In error: ${e.toString()}'));
      }
    }
  }

  Future<void> signInWithFacebook() async {
    if (_isClosed) return;

    log("🔵 Facebook Sign In: Starting in cubit...");
    emit(SocialAuthLoading());

    try {
      final result = await _repository.signInWithFacebook();
      log("🔵 Facebook Sign In: Repository result received");
      log("🔵 Facebook Sign In: Success = ${result['success']}");

      if (_isClosed) {
        log("❌ Facebook Sign In: Cubit is closed, aborting");
        return;
      }

      if (result['success'] == true) {
        log("✅ Facebook Sign In: SUCCESS CONDITION MET!");
        log("✅ Facebook Sign In: About to emit SocialAuthSuccess");

        emit(SocialAuthSuccess(result['user']));

        log("✅ Facebook Sign In: SocialAuthSuccess has been emitted!");
        log("✅ Facebook Sign In: Current state is: ${state.runtimeType}");
      } else {
        log("❌ Facebook Sign In: Success condition not met");
        emit(SocialAuthError(result['message'] ?? 'Facebook Sign-In failed'));
      }
    } catch (e, stackTrace) {
      log('❌ Facebook Sign In Error: $e');
      log('❌ Facebook Sign In Stack: $stackTrace');
      if (!_isClosed) {
        emit(SocialAuthError('Facebook Sign-In error: ${e.toString()}'));
      }
    }
  }

  Future<void> signOut() async {
    if (_isClosed) return;

    try {
      await _repository.signOut();
      emit(SocialAuthInitial());
    } catch (e) {
      log('Sign Out Error: $e');
      if (!_isClosed) {
        emit(SocialAuthError('Sign Out error: ${e.toString()}'));
      }
    }
  }

  Future<bool> updatePhoneNumber(String phoneNumber, String token) async {
    if (_isClosed) return false;

    try {
      return await _repository.updateUserPhone(phoneNumber, token);
    } catch (e) {
      log('Error updating phone: $e');
      return false;
    }
  }

  @override
  Future<void> close() {
    _isClosed = true;
    return super.close();
  }
}
