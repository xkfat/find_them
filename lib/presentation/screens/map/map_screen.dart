import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/presentation/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

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
    target: LatLng(18.7357, -15.9570),
    zoom: 10,
  );

  final Set<Marker> _markers = {};

  bool _isMapLoading = true;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;

    setState(() {
      _locationPermissionGranted = status.isGranted;
    });

    if (!status.isGranted) {
      final result = await Permission.location.request();
      setState(() {
        _locationPermissionGranted = result.isGranted;
      });
    }

    if (_locationPermissionGranted) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      setState(() {
        _initialCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        );
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );

        _isMapLoading = false;
      });
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(_initialCameraPosition),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isMapLoading = false;
      });
    }
  }

  void _addMissingPersonMarkers() {
    final currentPosition = _initialCameraPosition.target;
    _markers.addAll([
      Marker(
        markerId: const MarkerId('missing1'),
        position: LatLng(
          currentPosition.latitude + 0.01,
          currentPosition.longitude + 0.01,
        ),
        infoWindow: const InfoWindow(
          title: 'John Doe',
          snippet: 'Missing since: June 15, 2023',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        visible:
            _selectedFilter == 'All' || _selectedFilter == 'Missing persons',
      ),
      Marker(
        markerId: const MarkerId('missing2'),
        position: LatLng(
          currentPosition.latitude - 0.015,
          currentPosition.longitude + 0.005,
        ),
        infoWindow: const InfoWindow(
          title: 'Jane Smith',
          snippet: 'Missing since: July 22, 2023',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        visible:
            _selectedFilter == 'All' || _selectedFilter == 'Missing persons',
      ),
    ]);
    _markers.add(
      Marker(
        markerId: const MarkerId('sharing1'),
        position: LatLng(
          currentPosition.latitude - 0.008,
          currentPosition.longitude - 0.012,
        ),
        infoWindow: const InfoWindow(
          title: 'Alex Johnson',
          snippet: 'Sharing location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        visible:
            _selectedFilter == 'All' || _selectedFilter == 'Location sharing',
      ),
    );

    setState(() {});
  }

  void _filterMarkers(String filter) {
    setState(() {
      _selectedFilter = filter;
      _markers.forEach((marker) {
        final markerId = marker.markerId.value;

        if (markerId == 'currentLocation') {
          return;
        }
        if (markerId.startsWith('missing')) {
          final newMarker = marker.copyWith(
            visibleParam: filter == 'All' || filter == 'Missing persons',
          );
          _markers.remove(marker);
          _markers.add(newMarker);
        } else if (markerId.startsWith('sharing')) {
          final newMarker = marker.copyWith(
            visibleParam: filter == 'All' || filter == 'Location sharing',
          );
          _markers.remove(marker);
          _markers.add(newMarker);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),

                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildFilterOptions(),
              ],
            ),
          ),
          Expanded(child: _buildMapContainer()),
          ButtomNavBar(currentIndex: 1),
        ],
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
          hintText: 'Search',
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Row(
      children: [
        Expanded(child: _buildFilterButton('All')),
        const SizedBox(width: 8),
        Expanded(child: _buildFilterButton('Missing persons')),
        const SizedBox(width: 8),
        Expanded(child: _buildFilterButton('Location sharing')),
      ],
    );
  }

  Widget _buildFilterButton(String label) {
    final isSelected = _selectedFilter == label;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.darkGreen : AppColors.teal,
        foregroundColor: isSelected ? AppColors.white : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label),
    );
  }

  Widget _buildMapContainer() {
    if (_isMapLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.teal),
      );
    }

    if (!_locationPermissionGranted) {
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
              onPressed: _checkLocationPermission,
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

    return GoogleMap(
      initialCameraPosition: _initialCameraPosition,
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      compassEnabled: true,
      mapType: MapType.normal,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        _addMissingPersonMarkers();
      },
    );
  }
}
