import 'dart:async';
import 'dart:developer';
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
import 'package:find_them/presentation/helpers/localisation_extenstion.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;

  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(18.0892, -15.9777),
    zoom: 12,
  );

  final Set<Marker> _markers = {};
  List<Case> _filteredCases = [];
  List<UserLocationModel> _filteredFriendsLocations = [];

  Map<String, dynamic>? _navigationArgs;
  bool _shouldFocusOnUser = false;
  int? _focusUserId;

  // Performance optimizations with debouncing
  Timer? _markerUpdateTimer;
  bool _isUpdatingMarkers = false;

  @override
  void initState() {
    super.initState();
    log('MapScreen: Initializing...');
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _navigationArgs = args;
          _shouldFocusOnUser = args['focusOnUser'] == true;
          _focusUserId = args['userId'];
        });
        log(
          'MapScreen: Navigation args received - focusOnUser: $_shouldFocusOnUser, userId: $_focusUserId',
        );
      }
    });

    context.read<MapCubit>().checkLocationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _markerUpdateTimer?.cancel();
    CustomMarkerHelper.clearCache();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        log('App paused - reducing location update frequency');
        context.read<MapCubit>().stopAutomaticUpdates();
        CustomMarkerHelper.clearCache();
        break;
      case AppLifecycleState.resumed:
        log('App resumed - resuming location updates');
        context.read<MapCubit>().resumeAutomaticUpdates();
        context.read<MapCubit>().refreshMapData();
        break;
      case AppLifecycleState.detached:
        log('App detached - stopping all updates');
        context.read<MapCubit>().stopAutomaticUpdates();
        break;
      default:
        break;
    }
  }

  // Debounced marker updates for better performance
  Future<void> _updateMarkersDebounced({
    List<Case>? cases,
    List<UserLocationModel>? friendsLocations,
    List<LocationSharingModel>? friends,
    Position? currentPosition,
  }) async {
    _markerUpdateTimer?.cancel();

    _markerUpdateTimer = Timer(const Duration(milliseconds: 150), () {
      _updateMarkers(
        cases: cases,
        friendsLocations: friendsLocations,
        friends: friends,
        currentPosition: currentPosition,
      );
    });
  }

  Future<void> _updateMarkers({
    List<Case>? cases,
    List<UserLocationModel>? friendsLocations,
    List<LocationSharingModel>? friends,
    Position? currentPosition,
  }) async {
    if (_isUpdatingMarkers) return;

    _isUpdatingMarkers = true;
    log('MapScreen: Updating markers...');
    log('Cases count: ${cases?.length ?? 0}');
    log('Friends locations count: ${friendsLocations?.length ?? 0}');
    log('Friends count: ${friends?.length ?? 0}');
    log('Current position: $currentPosition');

    try {
      final Set<Marker> newMarkers = {};

      // Update camera position if needed
      if (currentPosition != null && !_shouldFocusOnUser) {
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
      log('Cases to show: ${casesToShow.length}');

      UserLocationModel? targetUserLocation;

      // Process cases
      for (final case_ in casesToShow) {
        log(
          'Processing case: ${case_.fullName}, lat: ${case_.latitude}, lng: ${case_.longitude}',
        );

        if (case_.latitude != null &&
            case_.longitude != null &&
            _shouldShowCaseMarker()) {
          log('Adding case marker: ${case_.fullName}');

          try {
            final customIcon = await CustomMarkerHelper.createCaseMarker(
              imageUrl: case_.photo,
              status: case_.status.value,
            );

            newMarkers.add(
              Marker(
                markerId: MarkerId('case_${case_.id}'),
                position: LatLng(case_.latitude!, case_.longitude!),
                icon: customIcon,
                anchor: const Offset(
                  0.5,
                  1.0,
                ), // Important for proper positioning
                infoWindow: InfoWindow(
                  title: case_.fullName,
                  snippet:
                      '${_getStatusText(case_.status.value)} • ${context.l10n.tapForDetails}',
                ),
                onTap: () => _onCaseMarkerTapped(case_),
              ),
            );
          } catch (e) {
            log('Error creating case marker, using fallback: $e');
            newMarkers.add(
              Marker(
                markerId: MarkerId('case_${case_.id}'),
                position: LatLng(case_.latitude!, case_.longitude!),
                icon: _getCaseMarkerIcon(case_.status.value),
                infoWindow: InfoWindow(
                  title: case_.fullName,
                  snippet:
                      '${_getStatusText(case_.status.value)} • ${context.l10n.tapForDetails}',
                ),
                onTap: () => _onCaseMarkerTapped(case_),
              ),
            );
          }
        }
      }

      // Process friends locations
      final friendsLocationsToShow =
          friendsLocations ?? _filteredFriendsLocations;
      log('Friends locations to show: ${friendsLocationsToShow.length}');

      for (final friendLocation in friendsLocationsToShow) {
        log(
          'Processing friend location: ${friendLocation.username}, lat: ${friendLocation.latitude}, lng: ${friendLocation.longitude}, freshness: ${friendLocation.freshness}',
        );

        if (_shouldFocusOnUser && _focusUserId == friendLocation.user) {
          targetUserLocation = friendLocation;
          log('Found target user location: ${friendLocation.username}');
        }

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

          log(
            'Adding friend marker: ${friendDetails?.friendDetails.displayName ?? friendLocation.username} (${friendLocation.freshness})',
          );

          try {
            final customIcon =
                await CustomMarkerHelper.createUserMarkerWithLiveIndicator(
                  imageUrl: friendDetails?.friendDetails.profilePhoto ?? '',
                  locationData: friendLocation,
                );

            newMarkers.add(
              Marker(
                markerId: MarkerId('friend_${friendLocation.user}'),
                position: LatLng(
                  friendLocation.latitude,
                  friendLocation.longitude,
                ),
                icon: customIcon,
                anchor: const Offset(
                  0.5,
                  1.0,
                ), // Important for proper positioning
                infoWindow: InfoWindow(
                  title:
                      friendDetails?.friendDetails.displayName ??
                      friendLocation.username,
                  snippet:
                      '${friendLocation.displayText} • ${context.l10n.tapForDetails}',
                ),
                onTap:
                    () =>
                        friendDetails != null
                            ? _onUserMarkerTapped(friendDetails, friendLocation)
                            : null,
              ),
            );
          } catch (e) {
            log('Error creating user marker, using fallback: $e');
            newMarkers.add(
              Marker(
                markerId: MarkerId('friend_${friendLocation.user}'),
                position: LatLng(
                  friendLocation.latitude,
                  friendLocation.longitude,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  friendLocation.isLive ? 120.0 : 195.0,
                ),
                infoWindow: InfoWindow(
                  title:
                      friendDetails?.friendDetails.displayName ??
                      friendLocation.username,
                  snippet:
                      '${friendLocation.displayText} • ${context.l10n.tapForDetails}',
                ),
                onTap:
                    () =>
                        friendDetails != null
                            ? _onUserMarkerTapped(friendDetails, friendLocation)
                            : null,
              ),
            );
          }
        }
      }

      log('Total markers created: ${newMarkers.length}');
      log('Marker cache size: ${CustomMarkerHelper.getCacheSize()}');

      if (mounted) {
        setState(() {
          _markers.clear();
          _markers.addAll(newMarkers);
        });
      }

      log('Markers updated in state: ${_markers.length}');

      // Handle focus on user if needed
      if (_shouldFocusOnUser &&
          targetUserLocation != null &&
          _mapController != null) {
        log('Focusing on target user: ${targetUserLocation.username}');
        await _focusOnUserLocation(targetUserLocation);
        _shouldFocusOnUser = false;
      }
    } catch (e) {
      log('❌ Error updating markers: $e');
    } finally {
      _isUpdatingMarkers = false;
    }
  }

  Future<void> _focusOnUserLocation(UserLocationModel userLocation) async {
    if (_mapController == null) return;

    final targetPosition = CameraPosition(
      target: LatLng(userLocation.latitude, userLocation.longitude),
      zoom: 16.0,
    );

    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(targetPosition),
    );

    log(
      'Camera focused on user: ${userLocation.username} at ${userLocation.latitude}, ${userLocation.longitude}',
    );
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
        return context.l10n.missing;
      case 'under_investigation':
      case 'investigating':
        return context.l10n.investigating;
      case 'found':
        return context.l10n.found;
      default:
        return context.l10n.missing;
    }
  }

  BitmapDescriptor _getCaseMarkerIcon(String status) {
    switch (status.toLowerCase()) {
      case 'missing':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'under_investigation':
      case 'investigating':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueYellow,
        );
      case 'found':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  void _onCaseMarkerTapped(Case case_) {
    Navigator.pushNamed(context, '/case/details', arguments: case_.id);
  }

  void _onUserMarkerTapped(
    LocationSharingModel friend,
    UserLocationModel locationData,
  ) {
    _showUserInfoDialog(friend, locationData);
  }

  void _showUserInfoDialog(
    LocationSharingModel friend,
    UserLocationModel locationData,
  ) {
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
                Stack(
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
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color:
                              locationData.isLive
                                  ? AppColors.getFoundGreenColor(context)
                                  : AppColors.teal,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
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
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        locationData.isLive
                            ? AppColors.getFoundGreenColor(context)
                            : AppColors.teal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    locationData.displayText,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  context,
                  locationData.isLive
                      ? context.l10n.liveLocation
                      : context.l10n.recentLocation,
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
                              context.l10n.sendAlert,
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
                          context.l10n.close,
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

  Widget _buildInfoRow(BuildContext context, String value) {
    return Center(
      child: Text(
        value,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.getTextColor(context),
        ),
      ),
    );
  }

  void _filterMarkers(String filter) {
    log('Filter changed to: $filter');
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

  void _onSearchSubmitted() async {
    final query = _searchController.text.trim();
    log('Search query: $query');

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

        await _zoomToSearchResults(filteredCases, filteredFriendsLocations);
      }
    }
  }

  Future<void> _zoomToSearchResults(
    List<Case> cases,
    List<UserLocationModel> friendsLocations,
  ) async {
    if (_mapController == null) return;

    List<LatLng> locations = [];

    for (final case_ in cases) {
      if (case_.latitude != null && case_.longitude != null) {
        locations.add(LatLng(case_.latitude!, case_.longitude!));
      }
    }

    for (final friendLocation in friendsLocations) {
      locations.add(LatLng(friendLocation.latitude, friendLocation.longitude));
    }

    if (locations.isEmpty) return;

    if (locations.length == 1) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: locations.first, zoom: 16.0),
        ),
      );
    } else {
      double minLat = locations.first.latitude;
      double maxLat = locations.first.latitude;
      double minLng = locations.first.longitude;
      double maxLng = locations.first.longitude;

      for (final location in locations) {
        minLat = minLat < location.latitude ? minLat : location.latitude;
        maxLat = maxLat > location.latitude ? maxLat : location.latitude;
        minLng = minLng < location.longitude ? minLng : location.longitude;
        maxLng = maxLng > location.longitude ? maxLng : location.longitude;
      }

      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          100.0,
        ),
      );
    }
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'All':
        return context.l10n.all;
      case 'Cases':
        return context.l10n.cases;
      case 'Users':
        return context.l10n.users;
      default:
        return filter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
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
                backgroundColor: AppColors.getMissingRedColor(context),
              ),
            );
          } else if (state is MapDataLoaded) {
            log('MapDataLoaded state received');
            _updateMarkers(
              cases: state.cases,
              friendsLocations: state.friendsLocations,
              friends: state.friends,
              currentPosition: state.currentPosition,
            );
          } else if (state is MapLocationUpdated) {
            log('MapLocationUpdated state received');
            _updateMarkers(currentPosition: state.position);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Container(
                color: AppColors.getBackgroundColor(context),
                padding: const EdgeInsets.only(
                  top: 50,
                  left: 31.0,
                  right: 31.0,
                  bottom: 16,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (_navigationArgs != null)
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: AppColors.getTextColor(context),
                            ),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        Expanded(
                          child: Text(
                            _navigationArgs != null
                                ? '${_navigationArgs!['displayName'] ?? _navigationArgs!['username']}\'${context.l10n.locationSuffix}'
                                : context.l10n.mapView,
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.getTextColor(context),
                            ),
                            textAlign:
                                _navigationArgs != null
                                    ? TextAlign.left
                                    : TextAlign.center,
                          ),
                        ),
                      ],
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
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.getDividerColor(context)),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: AppColors.getTextColor(context)),
        decoration: InputDecoration(
          hintText: context.l10n.searchCasesOrFriends,
          hintStyle: TextStyle(color: AppColors.getSecondaryTextColor(context)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              Icons.search,
              color: AppColors.getSecondaryTextColor(context),
            ),
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
        _getFilterLabel(label),
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMapContainer(MapState state) {
    if (state is MapLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.teal));
    }

    if (state is MapLocationPermissionRequired) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.locationPermissionRequired,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.getTextColor(context),
              ),
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
              child: Text(context.l10n.grantPermission),
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
              '${context.l10n.error}: ${state.message}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.getTextColor(context),
              ),
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
              child: Text(context.l10n.retry),
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
          log('Google Map created');
        },
      ),
    );
  }
}
