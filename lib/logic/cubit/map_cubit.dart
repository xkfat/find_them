import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:find_them/data/models/case.dart';
import 'package:find_them/data/models/location_sharing.dart';
import 'package:find_them/data/models/user_location.dart';
import 'package:find_them/data/repositories/map_repo.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final MapRepository _repository;

  MapCubit(this._repository) : super(MapInitial());

  /// Check and request location permissions
  Future<void> checkLocationPermission() async {
    try {
      final status = await Permission.location.status;

      if (!status.isGranted) {
        final result = await Permission.location.request();
        if (!result.isGranted) {
          emit(MapLocationPermissionRequired());
          return;
        }
      }

      await getCurrentLocation();
    } catch (e) {
      log('Error checking location permission: $e');
      emit(MapError('Failed to check location permission: $e'));
    }
  }

  /// Get current user location
  Future<void> getCurrentLocation() async {
    try {
      emit(MapLoading());

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      log('Current location: ${position.latitude}, ${position.longitude}');

      // Update location on backend
      await _repository.updateMyLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      emit(MapLocationUpdated(position));

      // Load map data after getting location
      await loadMapData(currentPosition: position);
    } catch (e) {
      log('Error getting current location: $e');
      emit(MapError('Failed to get current location: $e'));
    }
  }

  /// Load all map data (cases, friends locations, friends list)
  Future<void> loadMapData({Position? currentPosition}) async {
    try {
      emit(MapLoading());

      log('Loading map data...');

      // Load all data concurrently
      final results = await Future.wait([
        _repository.getCasesWithLocation(),
        _repository.getFriendsLocations(),
        _repository.getFriends(),
      ]);

      final cases = results[0] as List<Case>;
      final friendsLocations = results[1] as List<UserLocationModel>;
      final friends = results[2] as List<LocationSharingModel>;

      log('Loaded ${cases.length} cases, ${friendsLocations.length} friend locations, ${friends.length} friends');

      emit(MapDataLoaded(
        cases: cases,
        friendsLocations: friendsLocations,
        friends: friends,
        currentPosition: currentPosition,
      ));
    } catch (e) {
      log('Error loading map data: $e');
      emit(MapError('Failed to load map data: $e'));
    }
  }

  /// Refresh map data
  Future<void> refreshMapData() async {
    try {
      Position? currentPosition;
      
      if (state is MapDataLoaded) {
        currentPosition = (state as MapDataLoaded).currentPosition;
      }

      await loadMapData(currentPosition: currentPosition);
    } catch (e) {
      log('Error refreshing map data: $e');
      emit(MapError('Failed to refresh map data: $e'));
    }
  }

  /// Update user location
  Future<void> updateUserLocation(double latitude, double longitude) async {
    try {
      await _repository.updateMyLocation(
        latitude: latitude,
        longitude: longitude,
      );

      final position = Position(
        longitude: longitude,
        latitude: latitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      emit(MapLocationUpdated(position));
    } catch (e) {
      log('Error updating user location: $e');
      emit(MapError('Failed to update location: $e'));
    }
  }

  /// Send alert to friend
  Future<void> sendAlert(int friendId, String friendName) async {
    try {
      await _repository.sendAlert(friendId);
      emit(MapAlertSent('Alert sent to $friendName'));
      
      // Return to previous state after showing success message
      Timer(Duration(seconds: 2), () {
        if (state is MapAlertSent) {
          loadMapData();
        }
      });
    } catch (e) {
      log('Error sending alert: $e');
      emit(MapError('Failed to send alert: $e'));
    }
  }

  /// Filter data based on search query
  List<Case> filterCases(List<Case> cases, String query) {
    if (query.isEmpty) return cases;
    
    return cases.where((case_) =>
      case_.fullName.toLowerCase().contains(query.toLowerCase()) ||
      case_.lastSeenLocation.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Filter friends based on search query
  List<UserLocationModel> filterFriendsLocations(
    List<UserLocationModel> friendsLocations,
    List<LocationSharingModel> friends,
    String query,
  ) {
    if (query.isEmpty) return friendsLocations;

    final filteredFriendsIds = friends.where((friend) =>
      friend.friendDetails.displayName.toLowerCase().contains(query.toLowerCase()) ||
      friend.friendDetails.username.toLowerCase().contains(query.toLowerCase())
    ).map((friend) => friend.friendId).toList();

    return friendsLocations.where((location) =>
      filteredFriendsIds.contains(location.user)
    ).toList();
  }

  /// Reset to initial state
  void reset() {
    emit(MapInitial());
  }
}