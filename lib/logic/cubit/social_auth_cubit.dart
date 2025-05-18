import 'package:bloc/bloc.dart';
import 'package:find_them/data/repositories/social_auth_repo.dart';

part 'social_auth_state.dart';

class SocialAuthCubit extends Cubit<SocialAuthState> {
  final SocialAuthRepository _repository;
  bool _isClosed = false;

  SocialAuthCubit(this._repository) : super(SocialAuthInitial());

  Future<void> signInWithGoogle() async {
    if (_isClosed) return;

    emit(SocialAuthLoading());

    try {
      final result = await _repository.signInWithGoogle();

      if (_isClosed) return;

      if (result['success'] == true) {
        emit(SocialAuthSuccess(result['user']));
      } else {
        emit(SocialAuthError(result['message'] ?? 'Google Sign-In failed. Please try again.'));
      }
    } catch (e) {
      print('Google Sign In Error in Cubit: $e');
      if (!_isClosed) {
        emit(SocialAuthError('Google Sign-In error: ${e.toString()}'));
      }
    }
  }

  Future<void> signInWithFacebook() async {
    if (_isClosed) return;

    emit(SocialAuthLoading());

    try {
      final result = await _repository.signInWithFacebook();

      if (_isClosed) return;

      if (result['success'] == true) {
        emit(SocialAuthSuccess(result['user']));
      } else {
        emit(SocialAuthError(result['message'] ?? 'Facebook Sign-In failed. Please try again.'));
      }
    } catch (e) {
      print('Facebook Sign In Error in Cubit: $e');
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
      print('Sign Out Error: $e');
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
    print('Error updating phone: $e');
    return false;
  }
}

  @override
  Future<void> close() {
    _isClosed = true;
    return super.close();
  }
}