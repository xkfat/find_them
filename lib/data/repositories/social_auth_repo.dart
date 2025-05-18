import 'package:find_them/data/services/social_auth_service.dart';

class SocialAuthRepository {
  final SocialAuthService _socialAuthService;

  SocialAuthRepository(this._socialAuthService);

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final result = await _socialAuthService.signInWithGoogle();
      return result;
    } catch (e) {
      print('Repository Google Sign In Error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> signInWithFacebook() async {
    try {
      final result = await _socialAuthService.signInWithFacebook();
      return result;
    } catch (e) {
      print('Repository Facebook Sign In Error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> updateUserPhone(String phoneNumber, String token) async {
    return await _socialAuthService.updateUserPhone(phoneNumber, token);
  }

  Future<void> signOut() async {
    await _socialAuthService.signOut();
  }
}
