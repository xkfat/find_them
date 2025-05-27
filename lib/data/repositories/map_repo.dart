import 'package:find_them/data/models/user_location.dart';
import 'package:find_them/data/models/case.dart';
import 'package:find_them/data/models/location_sharing.dart';
import 'package:find_them/data/services/api_service.dart';
import 'package:find_them/data/services/map_service.dart';
import 'package:find_them/data/services/location_sharing_service.dart';

class MapRepository {
  final MapService _mapService;
  final LocationSharingService _locationSharingService;
  final ApiService _apiService;

  MapRepository(this._mapService, this._locationSharingService) : _apiService = ApiService();

  Future<String?> getAuthToken() async {
    return await _apiService.getAccessToken();
  }

  /// Get friends' locations for map display
  Future<List<UserLocationModel>> getFriendsLocations() async {
    try {
      final token = await getAuthToken();
      return await _mapService.getFriendsLocations(token: token);
    } catch (e) {
      throw Exception('Failed to get friends locations: $e');
    }
  }

  /// Update current user's location
  Future<void> updateMyLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final token = await getAuthToken();
      await _mapService.updateMyLocation(
        latitude: latitude,
        longitude: longitude,
        token: token,
      );
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  /// Get cases with location data for map display
  Future<List<Case>> getCasesWithLocation() async {
    try {
      final token = await getAuthToken();
      return await _mapService.getCasesWithLocation(token: token);
    } catch (e) {
      throw Exception('Failed to get cases with location: $e');
    }
  }

  /// Get friends list for user details
  Future<List<LocationSharingModel>> getFriends() async {
    try {
      final token = await getAuthToken();
      return await _locationSharingService.getFriends(token: token);
    } catch (e) {
      throw Exception('Failed to get friends: $e');
    }
  }

  /// Send alert to friend
  Future<void> sendAlert(int friendId) async {
    try {
      final token = await getAuthToken();
      await _locationSharingService.sendAlert(friendId, token: token);
    } catch (e) {
      throw Exception('Failed to send alert: $e');
    }
  }
}