import 'dart:convert';
import 'dart:developer';
import 'package:find_them/data/models/user_location.dart';
import 'package:find_them/data/models/case.dart';
import 'package:http/http.dart' as http;

class MapService {
  final String baseUrl;
  final http.Client _httpClient;

  MapService({
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

  /// Get friends' locations for map display
  Future<List<UserLocationModel>> getFriendsLocations({String? token}) async {
    try {
      log('Fetching friends locations for map');
      
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/location-sharing/locations/'),
        headers: _getHeaders(token: token),
      );

      log('Friends locations response status: ${response.statusCode}');
      log('Friends locations response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UserLocationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get friends locations: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getting friends locations: $e');
      throw Exception('Error getting friends locations: $e');
    }
  }

  /// Update current user's location
  Future<void> updateMyLocation({
    required double latitude,
    required double longitude,
    String? token,
  }) async {
    try {
      log('Updating my location: $latitude, $longitude');
      
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/location-sharing/locations/update/'),
        headers: _getHeaders(token: token),
        body: json.encode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      log('Update location response status: ${response.statusCode}');
      log('Update location response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to update location: ${response.statusCode}');
      }
    } catch (e) {
      log('Error updating location: $e');
      throw Exception('Error updating location: $e');
    }
  }

  /// Get cases with location data for map display
  Future<List<Case>> getCasesWithLocation({String? token}) async {
    try {
      log('Fetching cases with location data');
      
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/cases/'),
        headers: _getHeaders(token: token),
      );

      log('Cases response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> results = responseData['results'] ?? [];
        
        // Filter only cases that have location data
        final cases = results
            .map((json) => Case.fromJson(json))
            .where((case_) => case_.latitude != null && case_.longitude != null)
            .toList();
            
        log('Found ${cases.length} cases with location data');
        return cases;
      } else {
        throw Exception('Failed to load cases: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getting cases with location: $e');
      throw Exception('Error getting cases with location: $e');
    }
  }
}