
import 'dart:convert';
import 'package:find_them/core/constants/api_constants.dart';
import 'package:find_them/data/dataprovider/exception.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final http.Client _client;
  final FlutterSecureStorage _secureStorage;
  
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  ApiService({
    http.Client? client,
    FlutterSecureStorage? secureStorage,
  }) : 
    _client = client ?? http.Client(),
    _secureStorage = secureStorage ?? const FlutterSecureStorage();
  
  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> userData,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _secureStorage.write(key: _userDataKey, value: jsonEncode(userData));
  }

  Future<void> clearAuthTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userDataKey);
  }

  Future<bool> hasToken() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    return token != null;
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final userDataStr = await _secureStorage.read(key: _userDataKey);
    if (userDataStr != null) {
      return jsonDecode(userDataStr) as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getAccessToken();
    final headers = {'Content-Type': 'application/json'};
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getAuthHeaders();
    return _client.get(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
    );
  }
  
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getAuthHeaders();
    return _client.post(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }
  
  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getAuthHeaders();
    return _client.put(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

   Future<http.Response> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getAuthHeaders();
    return _client.patch(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }
  
  Future<http.Response> delete(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getAuthHeaders();
    return _client.delete(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }
Future<bool> refreshToken() async {
  final refreshToken = await getRefreshToken();
  if (refreshToken == null) return false;
  
  try {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.tokenRefresh}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );
    
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      await _secureStorage.write(key: _accessTokenKey, value: responseData['access']);
      return true;
    }
    return false;
  } catch (e) {
    return false;
  }
}
  Future<http.Response> authenticatedRequest(
  Future<http.Response> Function() requestFunction,
) async {
  try {
    final response = await requestFunction();
    
    if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) {
        return await requestFunction();
      } else {
        await clearAuthTokens();
        throw UnauthorisedException('Session expired');
      }
    }
    
    return response;
  } catch (e) {
    rethrow;
  }
}
}