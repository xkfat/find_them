import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final Map<String, String> _headers = {'Content-Type': 'application/json'};
  String? _authToken;

  ApiService({required this.baseUrl});

  void setAuthToken(String token) {
    _authToken = token;
    _headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _authToken = null;
    _headers.remove('Authorization');
  }
    Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    final Uri uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParameters);
    
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, {dynamic data}) async {
    final Uri uri = Uri.parse('$baseUrl$endpoint');
    
    final response = await http.post(
      uri,
      headers: _headers,
      body: data != null ? json.encode(data) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, {dynamic data}) async {
    final Uri uri = Uri.parse('$baseUrl$endpoint');
    
    final response = await http.put(
      uri,
      headers: _headers,
      body: data != null ? json.encode(data) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String endpoint, {dynamic data}) async {
    final Uri uri = Uri.parse('$baseUrl$endpoint');
    
    final response = await http.patch(
      uri,
      headers: _headers,
      body: data != null ? json.encode(data) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final Uri uri = Uri.parse('$baseUrl$endpoint');
    
    final response = await http.delete(uri, headers: _headers);
    return _handleResponse(response);
  }

  Future<dynamic> uploadFile(String endpoint, String filePath, String fieldName, {Map<String, String>? fields}) async {
    final Uri uri = Uri.parse('$baseUrl$endpoint');
    
    var request = http.MultipartRequest('POST', uri);
    
    if (_authToken != null) {
      request.headers['Authorization'] = 'Bearer $_authToken';
    }
    
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
    
    if (fields != null) {
      request.fields.addAll(fields);
    }
    
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return json.decode(response.body);
    } else {
      _handleError(response);
    }
  }

  void _handleError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        throw BadRequestException(response.body);
      case 401:
        throw UnauthorizedException(response.body);
      case 403:
        throw ForbiddenException(response.body);
      case 404:
        throw NotFoundException(response.body);
      case 500:
        throw ServerException(response.body);
      default:
        throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}

// Exceptions
class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);
  
  @override
  String toString() => message;
}

class BadRequestException extends ApiException {
  BadRequestException(String message) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

