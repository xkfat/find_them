import 'dart:developer' as dev;
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/data/models/case.dart';
import 'package:find_them/data/models/enum.dart';
import 'package:find_them/data/models/location_request.dart';
import 'package:find_them/data/models/location_sharing.dart';
import 'package:find_them/data/models/user_location.dart';
import 'package:find_them/logic/cubit/map_cubit.dart';
import 'package:find_them/presentation/helpers/marker_helper.dart';
import 'package:find_them/presentation/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;

  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 12,
  );

  final Set<Marker> _markers = {};

  List<Case> _filteredCases = [];
  List<UserLocationModel> _filteredFriendsLocations = [];

  @override
  void initState() {
    super.initState();
    dev.log('MapScreen: Initializing...');
    context.read<MapCubit>().checkLocationPermission();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _updateMarkers({
    List<Case>? cases,
    List<UserLocationModel>? friendsLocations,
    List<LocationSharingModel>? friends,
    Position? currentPosition,
  }) async {
    dev.log('MapScreen: Updating markers...');
    dev.log('Cases count: ${cases?.length ?? 0}');
    dev.log('Friends locations count: ${friendsLocations?.length ?? 0}');
    dev.log('Friends count: ${friends?.length ?? 0}');
    dev.log('Current position: $currentPosition');

    final Set<Marker> newMarkers = {};

    if (currentPosition != null) {
      dev.log(
        'Adding current location marker: ${currentPosition.latitude}, ${currentPosition.longitude}',
      );
      newMarkers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(currentPosition.latitude, currentPosition.longitude),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueTeal),
        ),
      );

      _initialCameraPosition = CameraPosition(
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: 15,
      );

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(_initialCameraPosition),
        );
      }
    }

    final casesToShow = cases ?? _filteredCases;
    dev.log('Cases to show: ${casesToShow.length}');

    for (final case_ in casesToShow) {
      dev.log(
        'Processing case: ${case_.fullName}, lat: ${case_.latitude}, lng: ${case_.longitude}',
      );

      if (case_.latitude != null &&
          case_.longitude != null &&
          _shouldShowCaseMarker()) {
        dev.log('Adding case marker: ${case_.fullName}');

        final customIcon = await CustomMarkerHelper.createCaseMarker(
          imageUrl: case_.photo,
          status: case_.status.value,
        );

        newMarkers.add(
          Marker(
            markerId: MarkerId('case_${case_.id}'),
            position: LatLng(case_.latitude!, case_.longitude!),
            icon: customIcon,
            infoWindow: InfoWindow(
              title: case_.fullName,
              snippet:
                  '${_getStatusText(case_.status.value)} • Tap for details',
            ),
            onTap: () => _onCaseMarkerTapped(case_),
          ),
        );
      } else {
        dev.log(
          'Skipping case marker: ${case_.fullName} - lat: ${case_.latitude}, lng: ${case_.longitude}, shouldShow: ${_shouldShowCaseMarker()}',
        );
      }
    }

    final friendsLocationsToShow =
        friendsLocations ?? _filteredFriendsLocations;
    dev.log('Friends locations to show: ${friendsLocationsToShow.length}');

    for (final friendLocation in friendsLocationsToShow) {
      dev.log(
        'Processing friend location: ${friendLocation.username}, lat: ${friendLocation.latitude}, lng: ${friendLocation.longitude}',
      );

      if (_shouldShowUserMarker()) {
        final friendDetails = friends?.firstWhere(
          (friend) => friend.friendId == friendLocation.user,
          orElse:
              () => LocationSharingModel(
                id: 0,
                userId: 0,
                friendId: friendLocation.user,
                createdAt: DateTime.now(),
                friendDetails: UserBasicInfo(
                  id: friendLocation.user,
                  username: friendLocation.username,
                  firstName: '',
                  lastName: '',
                  email: '',
                ),
                isSharing: friendLocation.isSharing,
                canSeeYou: false,
              ),
        );

        dev.log(
          'Adding friend marker: ${friendDetails?.friendDetails.displayName ?? friendLocation.username}',
        );

        final customIcon = await CustomMarkerHelper.createUserMarker(
          imageUrl: friendDetails?.friendDetails.profilePhoto ?? '',
        );

        newMarkers.add(
          Marker(
            markerId: MarkerId('friend_${friendLocation.user}'),
            position: LatLng(friendLocation.latitude, friendLocation.longitude),
            icon: customIcon,
            infoWindow: InfoWindow(
              title:
                  friendDetails?.friendDetails.displayName ??
                  friendLocation.username,
              snippet: 'Sharing location • Tap for details',
            ),
            onTap:
                () =>
                    friendDetails != null
                        ? _onUserMarkerTapped(friendDetails)
                        : null,
          ),
        );
      } else {
        dev.log(
          'Skipping friend marker: ${friendLocation.username} - shouldShow: ${_shouldShowUserMarker()}',
        );
      }
    }

    dev.log('Total markers created: ${newMarkers.length}');

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });

    dev.log('Markers updated in state: ${_markers.length}');
  }

  bool _shouldShowCaseMarker() {
    switch (_selectedFilter) {
      case 'All':
        return true;
      case 'Cases':
        return true;
      case 'Users':
        return false;
      default:
        return true;
    }
  }

  bool _shouldShowUserMarker() {
    switch (_selectedFilter) {
      case 'All':
        return true;
      case 'Cases':
        return false;
      case 'Users':
        return true;
      default:
        return true;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'missing':
        return 'Missing';
      case 'under_investigation':
      case 'investigating':
        return 'Investigating';
      case 'found':
        return 'Found';
      default:
        return 'Missing';
    }
  }

  double _getColorHue(Color color) {
    HSVColor hsvColor = HSVColor.fromColor(color);
    return hsvColor.hue;
  }

  void _onCaseMarkerTapped(Case case_) {
    Navigator.pushNamed(context, '/case/details', arguments: case_.id);
  }

  void _onUserMarkerTapped(LocationSharingModel friend) {
    _showUserInfoDialog(friend);
  }

  void _showUserInfoDialog(LocationSharingModel friend) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.teal,
                  ),
                  child: ClipOval(
                    child:
                        friend.friendDetails.profilePhoto != null
                            ? Image.network(
                              friend.friendDetails.profilePhoto!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/profile.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                            : Image.asset(
                              'assets/images/profile.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  friend.friendDetails.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                Text(
                  '@${friend.friendDetails.username}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  ' ',
                  friend.isSharing
                      ? 'Currently sharing location'
                      : 'Location sharing paused',
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          context.read<MapCubit>().sendAlert(
                            friend.friendId,
                            friend.friendDetails.displayName,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Send Alert',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          //TODO: send alert v location sharing screen and show dialog alert sent
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.teal),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Close',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.getTextColor(context),
            ),
          ),
        ),
      ],
    );
  }

  void _filterMarkers(String filter) {
    dev.log('Filter changed to: $filter');
    setState(() {
      _selectedFilter = filter;
    });

    if (context.read<MapCubit>().state is MapDataLoaded) {
      final state = context.read<MapCubit>().state as MapDataLoaded;
      _updateMarkers(
        cases: _filteredCases.isEmpty ? state.cases : _filteredCases,
        friendsLocations:
            _filteredFriendsLocations.isEmpty
                ? state.friendsLocations
                : _filteredFriendsLocations,
        friends: state.friends,
        currentPosition: state.currentPosition,
      );
    }
  }

  void _onSearchSubmitted() {
    final query = _searchController.text.trim();
    dev.log('Search query: $query');

    if (context.read<MapCubit>().state is MapDataLoaded) {
      final state = context.read<MapCubit>().state as MapDataLoaded;

      if (query.isEmpty) {
        setState(() {
          _filteredCases = [];
          _filteredFriendsLocations = [];
        });

        _updateMarkers(
          cases: state.cases,
          friendsLocations: state.friendsLocations,
          friends: state.friends,
          currentPosition: state.currentPosition,
        );
      } else {
        final filteredCases = context.read<MapCubit>().filterCases(
          state.cases,
          query,
        );
        final filteredFriendsLocations = context
            .read<MapCubit>()
            .filterFriendsLocations(
              state.friendsLocations,
              state.friends,
              query,
            );

        setState(() {
          _filteredCases = filteredCases;
          _filteredFriendsLocations = filteredFriendsLocations;
        });

        _updateMarkers(
          cases: filteredCases,
          friendsLocations: filteredFriendsLocations,
          friends: state.friends,
          currentPosition: state.currentPosition,
        );

        final totalResults =
            filteredCases.length + filteredFriendsLocations.length;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found $totalResults results for "$query"'),
            backgroundColor: AppColors.teal,
            action: SnackBarAction(
              label: 'Clear',
              textColor: Colors.white,
              onPressed: () {
                _searchController.clear();
                _onSearchSubmitted(); 
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MapCubit, MapState>(
        listener: (context, state) {
          if (state is MapAlertSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.teal,
              ),
            );
          } else if (state is MapError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is MapDataLoaded) {
            dev.log('MapDataLoaded state received');
            _updateMarkers(
              cases: state.cases,
              friendsLocations: state.friendsLocations,
              friends: state.friends,
              currentPosition: state.currentPosition,
            );
          } else if (state is MapLocationUpdated) {
            dev.log('MapLocationUpdated state received');
            _updateMarkers(currentPosition: state.position);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 48.0,
                      left: 31.0,
                      right: 31.0,
                      bottom: 16,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Map view',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        _buildSearchBar(),
                        const SizedBox(height: 16),
                        _buildFilterOptions(),
                      ],
                    ),
                  ),
                  Expanded(child: _buildMapContainer(state)),
                  ButtomNavBar(currentIndex: 1),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300),
      ),

      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search cases or friends...',

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: _onSearchSubmitted,
          ),
        ),
        onSubmitted: (_) => _onSearchSubmitted(),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Row(
      children: [
        Expanded(child: _buildFilterButton('All')),
        const SizedBox(width: 8),
        Expanded(child: _buildFilterButton('Cases')),
        const SizedBox(width: 8),
        Expanded(child: _buildFilterButton('Users')),
      ],
    );
  }

  Widget _buildFilterButton(String label) {
    final isSelected = _selectedFilter == label;

    return ElevatedButton(
      onPressed: () => _filterMarkers(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.darkGreen : AppColors.teal,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMapContainer(MapState state) {
    if (state is MapLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.teal),
      );
    }

    if (state is MapLocationPermissionRequired) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Location permission is required to use the map.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<MapCubit>().checkLocationPermission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      );
    }

    if (state is MapError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${state.message}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<MapCubit>().refreshMapData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<MapCubit>().refreshMapData();
      },
      child: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        compassEnabled: true,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          dev.log('Google Map created');
        },
      ),
    );
  }
}
