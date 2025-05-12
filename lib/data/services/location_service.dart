import 'package:dio/dio.dart';
import 'package:find_them/core/constants/api_constants.dart';
import 'package:find_them/data/models/location_request.dart';
import 'package:find_them/data/models/location_sharing.dart';
import 'package:find_them/data/models/user_location.dart';
import 'package:find_them/data/models/selected_friend.dart';
import 'package:find_them/data/services/api_service.dart';


class LocationService {
  late Dio dio;

  LocationService(ApiService apiService) {
    dio = apiService.dio;
  }

  Future<List<LocationRequest>> getPendingRequests() async {
    try {
      Response response = await dio.get(ApiConstants.locationRequests);
      
      return (response.data as List)
          .map((json) => LocationRequest.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<LocationRequest?> sendLocationRequest(String identifier) async {
    try {
      Response response = await dio.post(
        ApiConstants.sendLocationRequest,
        data: {'identifier': identifier},
      );
      
      return LocationRequest.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<bool> respondToRequest(int requestId, bool accept) async {
    try {
      String url = ApiConstants.respondToRequest.replaceAll('{id}', requestId.toString());
      await dio.post(
        url,
        data: {'response': accept ? 'accept' : 'decline'},
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<LocationSharing>> getFriends() async {
    try {
      Response response = await dio.get(ApiConstants.friends);
      
      return (response.data as List)
          .map((json) => LocationSharing.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> removeFriend(int friendId) async {
    try {
      String url = ApiConstants.removeFriend.replaceAll('{id}', friendId.toString());
      await dio.delete(url);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendAlert(int friendId) async {
    try {
      String url = ApiConstants.sendAlert.replaceAll('{id}', friendId.toString());
      await dio.post(url);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<UserLocation>> getFriendsLocations() async {
    try {
      Response response = await dio.get(ApiConstants.friendsLocations);
      
      return (response.data as List)
          .map((json) => UserLocation.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<UserLocation?> updateMyLocation(double? latitude, double? longitude) async {
    try {
      final Map<String, dynamic> data = {};

      
      if (latitude != null) {
        data['latitude'] = latitude;
      }
      
      if (longitude != null) {
        data['longitude'] = longitude;
      }
      
      Response response = await dio.post(
        ApiConstants.updateLocation,
        data: data,
      );
      
      return UserLocation.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSharingSettings() async {
    try {
      Response response = await dio.get(ApiConstants.currentSharingSettings);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<List<SelectedFriend>> getSelectedFriends() async {
    try {
      Response response = await dio.get(ApiConstants.selectedFriends);
      
      return (response.data as List)
          .map((json) => SelectedFriend.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> updateSharingSettings({
    required bool isSharing,
    required String sharingMode,
    List<int>? selectedFriends,
  }) async {
    try {
      final data = {
        'is_sharing': isSharing,
        'sharing_mode': sharingMode,
      };
      
      if (sharingMode == 'selected_friends' && selectedFriends != null) {
        data['selected_friends'] = selectedFriends;
      }
      
      Response response = await dio.put(
        ApiConstants.sharingSettings,
        data: data,
      );
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}