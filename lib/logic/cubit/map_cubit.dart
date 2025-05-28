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
  Timer? _locationUpdateTimer;
  Timer? _dataRefreshTimer;

  MapCubit(this._repository) : super(MapInitial());

  @override
  Future<void> close() {
    _locationUpdateTimer?.cancel();
    _dataRefreshTimer?.cancel();
    return super.close();
  }

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
      _startLocationUpdates();
      _startDataRefresh();
    } catch (e) {
      log('Error checking location permission: $e');
      emit(MapError('Failed to check location permission: $e'));
    }
  }

  /// Start periodic location updates (every 2 minutes)
  void _startLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(Duration(minutes: 2), (timer) async {
      try {
        log('Updating location automatically...');
        await _updateCurrentLocation();
      } catch (e) {
        log('Error in automatic location update: $e');
      }
    });
  }

  /// Start periodic data refresh (every 1 minute)
  void _startDataRefresh() {
    _dataRefreshTimer?.cancel();
    _dataRefreshTimer = Timer.periodic(Duration(minutes: 1), (timer) async {
      try {
        log('Refreshing map data automatically...');
        await refreshMapData();
      } catch (e) {
        log('Error in automatic data refresh: $e');
      }
    });
  }

  /// Update current location without emitting loading state
  Future<void> _updateCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      log(
        'Updated current location: ${position.latitude}, ${position.longitude}',
      );

      // Update location on backend
      await _repository.updateMyLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // If current state is MapDataLoaded, update it with new position
      if (state is MapDataLoaded) {
        final currentState = state as MapDataLoaded;
        emit(
          MapDataLoaded(
            cases: currentState.cases,
            friendsLocations: currentState.friendsLocations,
            friends: currentState.friends,
            currentPosition: position,
          ),
        );
      }
    } catch (e) {
      log('Error updating location: $e');
      // Don't emit error state for background updates
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
      // Only emit loading for initial load, not for refreshes
      if (state is! MapDataLoaded) {
        emit(MapLoading());
      }

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

      log(
        'Loaded ${cases.length} cases, ${friendsLocations.length} friend locations, ${friends.length} friends',
      );

      // Log location freshness
      for (final location in friendsLocations) {
        log(
          'Friend ${location.username}: ${location.displayText} (${location.freshness})',
        );
      }

      emit(
        MapDataLoaded(
          cases: cases,
          friendsLocations: friendsLocations,
          friends: friends,
          currentPosition: currentPosition,
        ),
      );
    } catch (e) {
      log('Error loading map data: $e');
      emit(MapError('Failed to load map data: $e'));
    }
  }

  /// Refresh map data (for pull-to-refresh and automatic updates)
  Future<void> refreshMapData() async {
    try {
      Position? currentPosition;

      if (state is MapDataLoaded) {
        currentPosition = (state as MapDataLoaded).currentPosition;
      }

      await loadMapData(currentPosition: currentPosition);
    } catch (e) {
      log('Error refreshing map data: $e');
      // Don't emit error for background refresh
      if (state is! MapDataLoaded) {
        emit(MapError('Failed to refresh map data: $e'));
      }
    }
  }

  /// Update user location manually
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

    return cases
        .where(
          (case_) =>
              case_.fullName.toLowerCase().contains(query.toLowerCase()) ||
              case_.lastSeenLocation.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
  }

  /// Filter friends based on search query
  List<UserLocationModel> filterFriendsLocations(
    List<UserLocationModel> friendsLocations,
    List<LocationSharingModel> friends,
    String query,
  ) {
    if (query.isEmpty) return friendsLocations;

    final filteredFriendsIds =
        friends
            .where(
              (friend) =>
                  friend.friendDetails.displayName.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  friend.friendDetails.username.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .map((friend) => friend.friendId)
            .toList();

    return friendsLocations
        .where((location) => filteredFriendsIds.contains(location.user))
        .toList();
  }

  /// Stop automatic updates
  void stopAutomaticUpdates() {
    _locationUpdateTimer?.cancel();
    _dataRefreshTimer?.cancel();
    log('Stopped automatic location updates');
  }

  /// Resume automatic updates
  void resumeAutomaticUpdates() {
    _startLocationUpdates();
    _startDataRefresh();
    log('Resumed automatic location updates');
  }

  /// Reset to initial state
  void reset() {
    _locationUpdateTimer?.cancel();
    _dataRefreshTimer?.cancel();
    emit(MapInitial());
  }
}
