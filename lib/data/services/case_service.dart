import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:find_them/data/models/case.dart';
import 'package:find_them/data/models/case_update.dart';

class CaseService {
  final String baseUrl;
  final http.Client _httpClient;
  final String? authToken;

  CaseService({
    this.baseUrl = 'http://10.0.2.2:8000/api',
    this.authToken,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  Future<List<Case>> getCases({
    String? name,
    String? lastSeenLocation,
    String? nameOrLocation,
    int? ageMin,
    int? ageMax,
    String? gender,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (nameOrLocation != null && nameOrLocation.isNotEmpty) {
        queryParams['name_or_location'] = nameOrLocation;
      } else {
        if (name != null && name.isNotEmpty) queryParams['name'] = name;
        if (lastSeenLocation != null && lastSeenLocation.isNotEmpty)
          queryParams['location'] = lastSeenLocation;
      }
      if (ageMin != null) queryParams['age_min'] = ageMin.toString();
      if (ageMax != null) queryParams['age_max'] = ageMax.toString();
      if (gender != null && gender.isNotEmpty) queryParams['gender'] = gender;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (startDate != null) queryParams['date_reported_start'] = startDate;
      if (endDate != null) queryParams['date_reported_end'] = endDate;

      final uri = Uri.parse(
        '$baseUrl/cases/',
      ).replace(queryParameters: queryParams);
      final response = await _httpClient.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> results = responseData['results'] ?? [];
        return results.map((json) => Case.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cases: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting cases: $e');
    }
  }

  Future<Case> getCaseById(int id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/cases/$id/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Case.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load case: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting case details: $e');
    }
  }

  Future<Case> getCaseWithUpdates(int id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/cases/$id/with-updates/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Case.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to load case with updates: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error getting case with updates: $e');
    }
  }

  Future<Case> submitCase({
    required String firstName,
    required String lastName,
    required int age,
    required String gender,
    required File photo,
    required String description,
    required DateTime lastSeenDate,
    required String lastSeenLocation,
    double? latitude,
    double? longitude,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/cases/'));
      if (authToken != null) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['age'] = age.toString();
      request.fields['gender'] = gender;
      request.fields['description'] = description;
      request.fields['last_seen_date'] =
          lastSeenDate.toIso8601String().split('T').first;
      request.fields['last_seen_location'] = lastSeenLocation;

      if (latitude != null) {
        request.fields['latitude'] = latitude.toString();
      }

      if (longitude != null) {
        request.fields['longitude'] = longitude.toString();
      }

      var photoFile = await http.MultipartFile.fromPath('photo', photo.path);
      request.files.add(photoFile);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return Case.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to submit case: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error submitting case: $e');
    }
  }
}
