import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:find_them/data/dataprovider/exception.dart';
import 'package:http/http.dart' as http;
import 'package:find_them/data/models/case.dart';

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

  Future<Case> submitCase({
    required String firstName,
    required String lastName,
    required int age,
    required String gender,
    required File photo,
    required String description,
    required DateTime lastSeenDate,
    required String lastSeenLocation,
    required String contactPhone, 
    double? latitude,
    double? longitude,
    String? authToken,
  }) async {
    try {
      log("submitCase");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/api/cases/'),
      );
          final token = authToken ?? this.authToken;

      if (token != null) {
        request.headers['Authorization'] = 'Token $token';
      }
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['age'] = age.toString();
      request.fields['gender'] = gender;
      request.fields['description'] = description;
      request.fields['last_seen_date'] =
          lastSeenDate.toIso8601String().split('T').first;
      request.fields['last_seen_location'] = lastSeenLocation;
request.fields['contact_phone'] = contactPhone;

      if (latitude != null) {
        request.fields['latitude'] = latitude.toString();
      }
      if (longitude != null) {
        request.fields['longitude'] = longitude.toString();
      }

      var photoFile = await http.MultipartFile.fromPath('photo', photo.path);
      request.files.add(photoFile);

      var streamedResponse = await request.send().timeout(
        Duration(seconds: 60),
      );
      var response = await http.Response.fromStream(streamedResponse);

      log("Submit case response status: ${response.statusCode}");
      log("Submit case response body: ${response.body}");

      Map<String, dynamic> responseJson;
      try {
        responseJson = json.decode(response.body);
      } catch (e) {
        log("Error parsing JSON: $e");
        responseJson = {"message": response.body};
      }

      switch (response.statusCode) {
        case 200:
        case 201:
          return Case.fromJson(responseJson);
        case 400:
          return Case.fromJson(responseJson);
        case 401:
        case 403:
          throw UnauthorisedException("Authentication failed");
        case 404:
          throw NotFoundException("Endpoint not found");
        case 500:
        default:
          throw FetchDataException("Server error: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      log("Socket Exception: $e");
      throw Failure(message: "Network error: Check your internet connection");
    } on TimeoutException catch (e) {
      log("Timeout Exception: $e");
      throw Failure(message: "Connection timed out");
    } on http.ClientException catch (e) {
      log("Client Exception: $e");
      throw Failure(message: "Client error: ${e.message}");
    } catch (e) {
      log("Unexpected error: $e");
      throw Failure(message: "An unexpected error occurred");
    }
  }
}
