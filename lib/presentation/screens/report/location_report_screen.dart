import 'package:flutter/material.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:find_them/presentation/helpers/localisation_extenstion.dart';

class ApiKeys {
  static const String googleMaps = "AIzaSyC_EsZPIvrGW3TcBuiDhybiltDIokgGEPY";
}

class LocationReportScreen extends StatefulWidget {
  const LocationReportScreen({super.key});

  @override
  State<LocationReportScreen> createState() => _LocationReportScreenState();
}

class _LocationReportScreenState extends State<LocationReportScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng _currentPosition = const LatLng(0, 0);
  LatLng _selectedPosition = const LatLng(0, 0);
  String _address = "";
  bool _isLoading = true;
  bool _initialLocationSet = false;
  double _currentZoom = 15.0;

  final Set<Marker> _markers = {};
  final String _apiKey = ApiKeys.googleMaps;
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _address = context.l10n.searchingYourLocation;
      });
    });
    _immediatelyGetUserLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    super.dispose();
  }

  Future<void> _immediatelyGetUserLocation() async {
    final location = loc.Location();
    await location.requestPermission();
    await location.requestService();

    location.onLocationChanged.listen((loc.LocationData currentLocation) {
      if (!_initialLocationSet &&
          currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        _initialLocationSet = true;
        final position = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );

        setState(() {
          _currentPosition = position;
          _selectedPosition = position;
          _isLoading = false;
          _updateMarker();
        });

        _moveToPosition(position);
        _getAddressFromLatLng(position);
      }
    });

    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      setState(() {
        _isLoading = false;
        _address = context.l10n.locationPermissionDenied;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.locationPermissionRequiredFeature),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    final location = loc.Location();
    bool serviceEnabled;
    loc.PermissionStatus permissionStatus;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _address = context.l10n.locationServiceDisabled;
        });
        return;
      }
    }
    permissionStatus = await location.hasPermission();
    if (permissionStatus == loc.PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != loc.PermissionStatus.granted) {
        setState(() {
          _isLoading = false;
          _address = context.l10n.locationPermissionDenied;
        });
        return;
      }
    }

    final currentLocation = await location.getLocation();
    if (currentLocation.latitude != null && currentLocation.longitude != null) {
      setState(() {
        _currentPosition = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
        _selectedPosition = _currentPosition;
        _updateMarker();
        _isLoading = false;
      });

      _moveToPosition(_currentPosition);
      _getAddressFromLatLng(_currentPosition);
    }
  }

  Future<void> _moveToPosition(LatLng position) async {
    if (_controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: _currentZoom),
        ),
      );
    }
  }

  Future<void> _zoomIn() async {
    if (_controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;
      _currentZoom += 1.0;
      if (_currentZoom > 20.0) _currentZoom = 20.0;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _selectedPosition, zoom: _currentZoom),
        ),
      );
    }
  }

  Future<void> _zoomOut() async {
    if (_controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;
      _currentZoom -= 1.0;
      if (_currentZoom < 2.0) _currentZoom = 2.0;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _selectedPosition, zoom: _currentZoom),
        ),
      );
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final components =
            [
              place.street,
              place.locality,
              place.administrativeArea,
              place.postalCode,
            ].where((e) => e != null && e.isNotEmpty).toList();

        setState(() {
          _address = components.join(", ");
          _searchController.text = _address;
        });
      } else {
        setState(() {
          _address = context.l10n.addressNotFound;
        });
      }
    } catch (e) {
      setState(() {
        _address = context.l10n.errorGettingAddress;
      });
    }
  }

  void _updateMarker() {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selectedLocation'),
          position: _selectedPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: context.l10n.selectedLocation,
            snippet: _address,
          ),
        ),
      );
    });
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _updateMarker();
    });
    _getAddressFromLatLng(position);
  }

  void _saveLocation() {
    String humanReadableLocation = _address;

    if (humanReadableLocation.contains('+') &&
        humanReadableLocation.contains(',')) {
      List<String> parts = _address.split(',');
      String firstPart = parts[0].trim();
      if (firstPart.contains('+') && firstPart.length < 10) {
        humanReadableLocation = parts.sublist(1).join(',').trim();
      }
    }

    Navigator.pop(context, {
      'latitude': _selectedPosition.latitude,
      'longitude': _selectedPosition.longitude,
      'humanReadableLocation': humanReadableLocation,
    });
  }

  Future<void> _searchPlace() async {
    TextEditingController searchInputController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];
    bool searching = false;
    String errorMessage = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            Future<void> searchPlaces(String query) async {
              if (query.isEmpty) {
                setModalState(() {
                  searchResults = [];
                  searching = false;
                  errorMessage = "";
                });
                return;
              }

              setModalState(() {
                searching = true;
                errorMessage = "";
              });

              try {
                final url = Uri.parse(
                  'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_apiKey',
                );

                final response = await http.get(url);

                if (response.statusCode == 200) {
                  final data = json.decode(response.body);

                  if (data['status'] == 'OK') {
                    final predictions = data['predictions'];

                    setModalState(() {
                      searchResults = List<Map<String, dynamic>>.from(
                        predictions.map(
                          (prediction) => {
                            'placeId': prediction['place_id'],
                            'mainText':
                                prediction['structured_formatting']['main_text'],
                            'secondaryText':
                                prediction['structured_formatting']['secondary_text'] ??
                                '',
                            'description': prediction['description'],
                          },
                        ),
                      );
                      searching = false;
                    });
                  } else {
                    final errorMsg =
                        data['error_message'] ?? context.l10n.noResultsFound;

                    setModalState(() {
                      searchResults = [];
                      searching = false;
                      errorMessage = "${context.l10n.error}: $errorMsg";
                    });

                    if (data['status'] == 'REQUEST_DENIED') {
                      setModalState(() {
                        errorMessage =
                            "${context.l10n.apiKeyError}: ${data['error_message'] ?? context.l10n.invalidApiKey}";
                      });
                    } else if (data['status'] == 'ZERO_RESULTS') {
                      setModalState(() {
                        errorMessage = context.l10n.noMatchingLocations;
                      });
                    }
                  }
                } else {
                  setModalState(() {
                    searchResults = [];
                    searching = false;
                    errorMessage =
                        "${context.l10n.error}: HTTP ${response.statusCode}";
                  });
                }
              } catch (e) {
                setModalState(() {
                  searchResults = [];
                  searching = false;
                  errorMessage = "${context.l10n.networkError}: $e";
                });
              }
            }

            Future<void> selectPlace(String placeId) async {
              Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });

              try {
                final url = Uri.parse(
                  'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_address,geometry&key=$_apiKey',
                );

                final response = await http.get(url);

                if (response.statusCode == 200) {
                  final data = json.decode(response.body);

                  if (data['status'] == 'OK') {
                    final result = data['result'];
                    final lat = result['geometry']['location']['lat'];
                    final lng = result['geometry']['location']['lng'];
                    final address = result['formatted_address'];

                    setState(() {
                      _selectedPosition = LatLng(lat, lng);
                      _address = address;
                      _searchController.text = address;
                      _updateMarker();
                      _isLoading = false;
                    });

                    _moveToPosition(_selectedPosition);
                  } else {
                    setState(() {
                      _isLoading = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "${context.l10n.errorGettingPlaceDetails}: ${data['status']}",
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  setState(() {
                    _isLoading = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${context.l10n.error}: ${response.statusCode}",
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                setState(() {
                  _isLoading = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "${context.l10n.errorGettingPlaceDetails}: $e",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: TextField(
                            controller: searchInputController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: context.l10n.searchForLocation,
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              if (_debounceTimer?.isActive ?? false) {
                                _debounceTimer!.cancel();
                              }

                              _debounceTimer = Timer(
                                const Duration(milliseconds: 500),
                                () {
                                  if (value == searchInputController.text &&
                                      value.isNotEmpty) {
                                    searchPlaces(value);
                                  }
                                },
                              );
                            },
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                searchPlaces(value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child:
                          searching
                              ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.teal,
                                ),
                              )
                              : searchResults.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      errorMessage.isNotEmpty
                                          ? errorMessage
                                          : context.l10n.enterLocationToSearch,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color:
                                            errorMessage.isNotEmpty
                                                ? Colors.red
                                                : Colors.grey,
                                      ),
                                    ),
                                    if (errorMessage.contains(
                                      context.l10n.apiKeyError,
                                    ))
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          context.l10n.makeSurePlacesApiEnabled,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                              : ListView.builder(
                                itemCount: searchResults.length,
                                itemBuilder: (context, index) {
                                  final place = searchResults[index];
                                  return ListTile(
                                    leading: const Icon(
                                      Icons.location_on,
                                      color: AppColors.teal,
                                    ),
                                    title: Text(place['mainText']),
                                    subtitle: Text(place['secondaryText']),
                                    onTap: () => selectPlace(place['placeId']),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.teal,
        title: Text(
          context.l10n.setLocation,
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 2,
            ),
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              if (_initialLocationSet) {
                _moveToPosition(_currentPosition);
              }
            },
            onTap: _onMapTap,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                readOnly: true,
                onTap: _searchPlace,
                decoration: InputDecoration(
                  hintText: context.l10n.searchForLocation,
                  prefixIcon: const Icon(Icons.search, color: AppColors.teal),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.my_location, color: AppColors.teal),
                    onPressed: () {
                      _getCurrentLocation();
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: 260,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkGreen,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: AppColors.teal),
                    onPressed: _zoomIn,
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkGreen,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.remove, color: AppColors.teal),
                    onPressed: _zoomOut,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 240,
              color: AppColors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.selectLocation,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      _address,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          context.l10n.saveLocation,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
