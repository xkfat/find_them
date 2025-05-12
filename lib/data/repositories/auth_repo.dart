import '../models/user.dart';
import '../services/api/auth_api.dart';
import '../services/local/secure_storage_service.dart';

class AuthResult {
  final User user;
  final String token;
  
  AuthResult({required this.user, required this.token});
}

class AuthRepository {
  final AuthApiService authApiService;
  final SecureStorageService secureStorage;
  
  AuthRepository({
    required this.authApiService,
    required this.secureStorage,
  });
  
  Future<AuthResult> login(String username, String password) async {
    final response = await authApiService.login(username, password);
    return AuthResult(
      user: User.fromJson(response['user']),
      token: response['access'],
    );
  }
  
  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    final response = await authApiService.register(
      username: username,
      email: email,
      password: password,
      password2: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    );
    
    return AuthResult(
      user: User.fromJson(response['user']),
      token: response['access'],
    );
  }
  
  Future<User> getCurrentUser() async {
    final response = await authApiService.getProfile();
    return User.fromJson(response);
  }
  
  Future<void> storeToken(String token) async {
    await secureStorage.write(key: 'auth_token', value: token);
  }
  
  Future<String?> getStoredToken() async {
    return await secureStorage.read(key: 'auth_token');
  }
  
  Future<void> clearToken() async {
    await secureStorage.delete(key: 'auth_token');
  }
}