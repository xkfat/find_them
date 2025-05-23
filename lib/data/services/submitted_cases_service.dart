import 'dart:convert';
import 'dart:developer';
import 'package:find_them/core/constants/api_constants.dart';
import 'package:find_them/data/dataprovider/exception.dart';
import 'package:find_them/data/models/submitted_case.dart';
import 'package:http/http.dart' as http;

class SubmittedCaseService {
  final String baseUrl;
  final http.Client _httpClient;

  SubmittedCaseService({
    this.baseUrl = 'http://10.0.2.2:8000/api',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Map<String, String> _getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<SubmittedCase>> getSubmittedCases({String? token}) async {
    try {
      log("Fetching submitted cases for current user");
      
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/${ApiConstants.submittedCases}'),
        headers: _getHeaders(token: token),
      );

      log("Submitted cases response status: ${response.statusCode}");
      log("Submitted cases response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        List<dynamic> results;
        if (responseData is List<dynamic>) {
          results = responseData;
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('results')) {
          results = responseData['results'] as List<dynamic>;
        } else {
          throw Exception('Unexpected API response format: expected List or Map with results field');
        }
        
        return results.map((json) {
          if (json is Map<String, dynamic>) {
            return SubmittedCase.fromJson(json);
          } else {
            throw Exception('Invalid item format in API response');
          }
        }).toList();
      } else if (response.statusCode == 401) {
        throw UnauthorisedException('Authentication failed');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Submitted cases endpoint not found');
      } else {
        throw Exception('Failed to load submitted cases: ${response.statusCode}');
      }
    } catch (e) {
      log("Error getting submitted cases: $e");
      throw Exception('Error getting submitted cases: $e');
    }
  }

  Future<SubmittedCase> getCaseDetails(int caseId, {String? token}) async {
    try {
      log("Fetching case details with updates for case ID: $caseId");
      
      final url = ApiConstants.caseWithUpdates.replaceAll('{id}', caseId.toString());
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/$url'),
        headers: _getHeaders(token: token),
      );

      log("Case details response status: ${response.statusCode}");
      log("Case details response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return SubmittedCase.fromJsonWithUpdates(responseData);
      } else if (response.statusCode == 401) {
        throw UnauthorisedException('Authentication failed');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Case not found');
      } else {
        throw Exception('Failed to load case details: ${response.statusCode}');
      }
    } catch (e) {
      log("Error getting case details: $e");
      throw Exception('Error getting case details: $e');
    }
  }

  Future<List<CaseUpdateItem>> getCaseUpdates(int caseId, {String? token}) async {
    try {
      log("Fetching updates for case ID: $caseId");
      
      final url = ApiConstants.caseUpdates.replaceAll('{id}', caseId.toString());
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/$url'),
        headers: _getHeaders(token: token),
      );

      log("Case updates response status: ${response.statusCode}");
      log("Case updates response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> results = responseData['results'] ?? responseData;
        
        return results.map((json) => CaseUpdateItem.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw UnauthorisedException('Authentication failed');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Case updates not found');
      } else {
        throw Exception('Failed to load case updates: ${response.statusCode}');
      }
    } catch (e) {
      log("Error getting case updates: $e");
      throw Exception('Error getting case updates: $e');
    }
  }

  Future<SubmittedCase> getCaseWithUpdates(int caseId, {String? token}) async {
    try {
      log("Fetching case with updates for case ID: $caseId");
      
      final url = ApiConstants.caseWithUpdates.replaceAll('{id}', caseId.toString());
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/$url'),
        headers: _getHeaders(token: token),
      );

      log("Case with updates response status: ${response.statusCode}");
      log("Case with updates response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return SubmittedCase.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw UnauthorisedException('Authentication failed');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Case not found');
      } else {
        throw Exception('Failed to load case with updates: ${response.statusCode}');
      }
    } catch (e) {
      log("Error getting case with updates: $e");
      throw Exception('Error getting case with updates: $e');
    }
  }
}