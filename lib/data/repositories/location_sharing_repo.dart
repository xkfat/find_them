import 'package:find_them/data/models/user_search.dart';

import '../services/api_service.dart';
import '../services/location_sharing_service.dart';
import '../../data/models/location_sharing.dart';
import '../../data/models/location_request.dart';

class LocationSharingRepository {
  final LocationSharingService _service;
  final ApiService _apiService;

  LocationSharingRepository(this._service) : _apiService = ApiService();

  Future<String?> getAuthToken() async {
    return await _apiService.getAccessToken();
  }

  Future<List<LocationRequestModel>> getPendingRequests() async {
    try {
      final token = await getAuthToken();
      return await _service.getPendingRequests(token: token);
    } catch (e) {
      throw Exception('Failed to get pending requests: $e');
    }
  }

  Future<List<LocationSharingModel>> getFriends() async {
    try {
      final token = await getAuthToken();
      return await _service.getFriends(token: token);
    } catch (e) {
      throw Exception('Failed to get friends: $e');
    }
  }

  Future<void> acceptRequest(int requestId) async {
    try {
      final token = await getAuthToken();
      return await _service.respondToRequest(requestId, 'accept', token: token);
    } catch (e) {
      throw Exception('Failed to accept request: $e');
    }
  }

  Future<void> declineRequest(int requestId) async {
    try {
      final token = await getAuthToken();
      return await _service.respondToRequest(
        requestId,
        'decline',
        token: token,
      );
    } catch (e) {
      throw Exception('Failed to decline request: $e');
    }
  }

  Future<void> removeFriend(int friendId) async {
    try {
      final token = await getAuthToken();
      return await _service.removeFriend(friendId, token: token);
    } catch (e) {
      throw Exception('Failed to remove friend: $e');
    }
  }

  Future<void> sendAlert(int friendId) async {
    try {
      final token = await getAuthToken();
      return await _service.sendAlert(friendId, token: token);
    } catch (e) {
      throw Exception('Failed to send alert: $e');
    }
  }

  Future<void> sendLocationRequest(String identifier) async {
    try {
      final token = await getAuthToken();
      return await _service.sendLocationRequest(identifier, token: token);
    } catch (e) {
      throw Exception('Failed to send location request: $e');
    }
  }

  Future<List<UserSearchModel>> searchUsers(String query) async {
    try {
      final token = await getAuthToken();
      return await _service.searchUsers(query, token: token);
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // NEW: Toggle location sharing for specific friend
  Future<void> toggleFriendLocationSharing(int friendId, bool shouldShare) async {
    try {
      final token = await getAuthToken();
      return await _service.toggleFriendLocationSharing(
        friendId,
        shouldShare,
        token: token,
      );
    } catch (e) {
      throw Exception('Failed to toggle friend location sharing: $e');
    }
  }

  // NEW: Update general sharing settings
  Future<Map<String, dynamic>> updateSharingSettings({
    bool? isSharing,
    String? sharingMode,
    List<int>? selectedFriends,
  }) async {
    try {
      final token = await getAuthToken();
      return await _service.updateSharingSettings(
        isSharing: isSharing,
        sharingMode: sharingMode,
        selectedFriends: selectedFriends,
        token: token,
      );
    } catch (e) {
      throw Exception('Failed to update sharing settings: $e');
    }
  }

  // NEW: Get current sharing settings
  Future<Map<String, dynamic>> getSharingSettings() async {
    try {
      final token = await getAuthToken();
      return await _service.getSharingSettings(token: token);
    } catch (e) {
      throw Exception('Failed to get sharing settings: $e');
    }
  }

  // NEW: Get selected friends
  Future<List<dynamic>> getSelectedFriends() async {
    try {
      final token = await getAuthToken();
      return await _service.getSelectedFriends(token: token);
    } catch (e) {
      throw Exception('Failed to get selected friends: $e');
    }
  }
}