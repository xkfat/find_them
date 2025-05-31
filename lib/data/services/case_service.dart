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
        queryParams['name_or_location'] = Uri.encodeComponent(nameOrLocation);
      } else {
        if (name != null && name.isNotEmpty)
          queryParams['name'] = Uri.encodeComponent(name);
        if (lastSeenLocation != null && lastSeenLocation.isNotEmpty) {
          queryParams['location'] = Uri.encodeComponent(lastSeenLocation);
        }
      }
      if (ageMin != null) queryParams['age_min'] = ageMin.toString();
      if (ageMax != null) queryParams['age_max'] = ageMax.toString();
      if (gender != null && gender.isNotEmpty)
        queryParams['gender'] = Uri.encodeComponent(gender);
      if (status != null && status.isNotEmpty)
        queryParams['status'] = Uri.encodeComponent(status);
      if (startDate != null) queryParams['date_reported_start'] = startDate;
      if (endDate != null) queryParams['date_reported_end'] = endDate;

      final uri = Uri.parse(
        '$baseUrl/cases/',
      ).replace(queryParameters: queryParams);
      final response = await _httpClient.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = _parseJsonResponse(response);
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
        final responseData = _parseJsonResponse(response);
        return Case.fromJson(responseData);
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
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json; charset=utf-8';
      request.headers['Accept-Charset'] = 'utf-8';

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
        final roundedLatitude = double.parse(latitude.toStringAsFixed(6));
        request.fields['latitude'] = roundedLatitude.toString();
        log(
          "DEBUG: Added rounded latitude to request: $roundedLatitude (original: $latitude)",
        );
      }

      if (longitude != null) {
        final roundedLongitude = double.parse(longitude.toStringAsFixed(6));
        request.fields['longitude'] = roundedLongitude.toString();
        log(
          "DEBUG: Added rounded longitude to request: $roundedLongitude (original: $longitude)",
        );
      }

      var photoFile = await http.MultipartFile.fromPath('photo', photo.path);
      request.files.add(photoFile);

      var streamedResponse = await request.send().timeout(
        Duration(seconds: 60),
      );
      var response = await http.Response.fromStream(streamedResponse);

      log("Submit case response status: ${response.statusCode}");
      log("Submit case response body: ${_decodeResponse(response)}");

      Map<String, dynamic> responseJson;
      try {
        responseJson = _parseJsonResponse(response);
      } catch (e) {
        log("Error parsing JSON: $e");
        responseJson = {"message": _decodeResponse(response)};
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

  String _decodeResponse(http.Response response) {
    try {
      return utf8.decode(response.bodyBytes);
    } catch (e) {
      log("UTF-8 decoding failed, falling back to body string: $e");
      return response.body;
    }
  }

  Map<String, dynamic> _parseJsonResponse(http.Response response) {
    try {
      final decodedBody = _decodeResponse(response);
      return json.decode(decodedBody) as Map<String, dynamic>;
    } catch (e) {
      log("JSON parsing error: $e");
      throw Exception('Failed to parse server response');
    }
  }
}
