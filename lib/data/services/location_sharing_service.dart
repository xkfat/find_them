import 'dart:convert';
import 'dart:developer';
import 'package:find_them/data/models/user_search.dart';
import 'package:http/http.dart' as http;
import '../../data/models/location_request.dart';
import '../../data/models/location_sharing.dart';

class LocationSharingService {
  final String baseUrl = 'http://10.0.2.2:8000';

  Future<List<LocationRequestModel>> getPendingRequests({String? token}) async {
    try {
      log('Fetching pending location requests');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/location-sharing/requests/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      log('Pending requests response status: ${response.statusCode}');
      log('Pending requests response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => LocationRequestModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get pending requests: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getting pending requests: $e');
      throw Exception('Error getting pending requests: $e');
    }
  }

  Future<List<LocationSharingModel>> getFriends({String? token}) async {
    try {
      log('Fetching location sharing friends');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/location-sharing/friends/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      log('Friends response status: ${response.statusCode}');
      log('Friends response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final friends = data.map((json) => LocationSharingModel.fromJson(json)).toList();
        
        for (var friend in friends) {
          log('Friend ${friend.friendDetails.displayName}: canSeeYou = ${friend.canSeeYou}, isSharing = ${friend.isSharing}');
        }
        
        return friends;
      } else {
        throw Exception('Failed to get friends: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getting friends: $e');
      throw Exception('Error getting friends: $e');
    }
  }

  Future<void> respondToRequest(int requestId, String response, {String? token}) async {
    try {
      log('Responding to request $requestId with $response');
      
      final result = await http.post(
        Uri.parse('$baseUrl/api/location-sharing/requests/$requestId/respond/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'response': response}),
      );

      log('Respond to request status: ${result.statusCode}');
      log('Respond to request body: ${result.body}');

      if (result.statusCode != 200) {
        throw Exception('Failed to respond to request: ${result.statusCode}');
      }
    } catch (e) {
      log('Error responding to request: $e');
      throw Exception('Error responding to request: $e');
    }
  }

  Future<void> removeFriend(int friendId, {String? token}) async {
    try {
      log('Removing friend $friendId');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/api/location-sharing/friends/$friendId/remove/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      log('Remove friend status: ${response.statusCode}');

      if (response.statusCode != 204) {
        throw Exception('Failed to remove friend: ${response.statusCode}');
      }
    } catch (e) {
      log('Error removing friend: $e');
      throw Exception('Error removing friend: $e');
    }
  }

  Future<void> sendAlert(int friendId, {String? token}) async {
    try {
      log('Sending alert to friend $friendId');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/location-sharing/friends/$friendId/alert/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      log('Send alert status: ${response.statusCode}');
      log('Send alert body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to send alert: ${response.statusCode}');
      }
    } catch (e) {
      log('Error sending alert: $e');
      throw Exception('Error sending alert: $e');
    }
  }

  Future<void> sendLocationRequest(String identifier, {String? token}) async {
    try {
      log('Sending location request to $identifier');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/location-sharing/requests/send/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'identifier': identifier}),
      );

      log('Send request status: ${response.statusCode}');
      log('Send request body: ${response.body}');

      if (response.statusCode != 201) {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['detail'] ?? 'Failed to send request');
      }
    } catch (e) {
      log('Error sending request: $e');
      throw Exception('Error sending request: $e');
    }
  }

  Future<List<UserSearchModel>> searchUsers(String query, {String? token}) async {
    try {
      log('Searching users with query: $query');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/location-sharing/search-users/?q=$query'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      log('Search users response status: ${response.statusCode}');
      log('Search users response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UserSearchModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search users: ${response.statusCode}');
      }
    } catch (e) {
      log('Error searching users: $e');
      throw Exception('Error searching users: $e');
    }
  }

  Future<Map<String, dynamic>> toggleGlobalSharing(bool isSharing, {String? token}) async {
    try {
      log('Toggling global sharing to $isSharing');
      
      final response = await http.put(
        Uri.parse('$baseUrl/api/location-sharing/settings/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'is_sharing': isSharing}),
      );

      log('Toggle global sharing status: ${response.statusCode}');
      log('Toggle global sharing body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to toggle global sharing: ${response.statusCode}');
      }
    } catch (e) {
      log('Error toggling global sharing: $e');
      throw Exception('Error toggling global sharing: $e');
    }
  }

  Future<Map<String, dynamic>> toggleFriendSharing(int friendId, bool canSeeMe, {String? token}) async {
    try {
      log('Toggling friend $friendId sharing to $canSeeMe');
      
      final response = await http.put(
        Uri.parse('$baseUrl/api/location-sharing/friends/$friendId/toggle-sharing/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'can_see_me': canSeeMe}),
      );

      log('Toggle friend sharing status: ${response.statusCode}');
      log('Toggle friend sharing body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to toggle friend sharing: ${response.statusCode}');
      }
    } catch (e) {
      log('Error toggling friend sharing: $e');
      throw Exception('Error toggling friend sharing: $e');
    }
  }

  Future<Map<String, dynamic>> getSharingSettings({String? token}) async {
    try {
      log('Getting sharing settings');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/location-sharing/settings/current/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      log('Get sharing settings status: ${response.statusCode}');
      log('Get sharing settings body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get sharing settings: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getting sharing settings: $e');
      throw Exception('Error getting sharing settings: $e');
    }
  }
}