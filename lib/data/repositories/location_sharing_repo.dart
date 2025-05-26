import 'package:find_them/data/models/user_search.dart';
import 'package:find_them/data/models/location_request.dart';
import 'package:find_them/data/models/location_sharing.dart';
import 'package:find_them/data/services/api_service.dart';
import 'package:find_them/data/services/location_sharing_service.dart';

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

  Future<void> removeFriend(int friendId, {String? token}) async {
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

  Future<Map<String, dynamic>> toggleGlobalSharing(bool isSharing) async {
    try {
      final token = await getAuthToken();
      return await _service.toggleGlobalSharing(isSharing, token: token);
    } catch (e) {
      throw Exception('Failed to toggle global sharing: $e');
    }
  }

  Future<Map<String, dynamic>> toggleFriendSharing(
    int friendId,
    bool canSeeMe,
  ) async {
    try {
      final token = await getAuthToken();
      return await _service.toggleFriendSharing(
        friendId,
        canSeeMe,
        token: token,
      );
    } catch (e) {
      throw Exception('Failed to toggle friend sharing: $e');
    }
  }

  Future<Map<String, dynamic>> getSharingSettings() async {
    try {
      final token = await getAuthToken();
      return await _service.getSharingSettings(token: token);
    } catch (e) {
      throw Exception('Failed to get sharing settings: $e');
    }
  }
}
