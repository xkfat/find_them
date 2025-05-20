import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/logic/cubit/submit_case_cubit.dart';
import 'package:find_them/presentation/screens/report/location_report_screen.dart';
import 'package:find_them/presentation/screens/report/report_screen3.dart';
import 'package:find_them/presentation/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; 

class Report2Screen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final int age;
  final String gender;

  const Report2Screen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.gender,
  });

  @override
  State<Report2Screen> createState() => _Report2ScreenState();
}

class _Report2ScreenState extends State<Report2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _lastSeenDateController = TextEditingController();
  final _lastSeenLocationController = TextEditingController();
  DateTime? _selectedDate;
  double? _latitude;
  double? _longitude;
  String? _address;
  Set<Marker> _markers = {}; 
  GoogleMapController? _mapController; 

  @override
  void dispose() {
    _lastSeenDateController.dispose();
    _lastSeenLocationController.dispose();
    _mapController?.dispose(); 
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _lastSeenDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _continueToNextStep() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select a date')));
        return;
      }
          String humanReadableLocation = _lastSeenLocationController.text;

      Navigator.pushNamed(
        context,
        '/report3',
        arguments: {
          'firstName': widget.firstName,
          'lastName': widget.lastName,
          'age': widget.age,
          'gender': widget.gender,
          'lastSeenDate': _selectedDate,
          'lastSeenLocation': humanReadableLocation,
          'latitude': _latitude,
          'longitude': _longitude,
        },
      );
    }
  }

  void _updateMapLocation(double lat, double lng, String? addr) {
    setState(() {
      _latitude = lat;
      _longitude = lng;
      _address = addr;

      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: 'Last Seen Location', snippet: addr),
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Reporting a missing person',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCompletedStep(),
                    _buildStepLine(true),
                    _buildActiveStep(2),
                    _buildStepLine(false),
                    _buildInactiveStep(3),
                  ],
                ),
                const SizedBox(height: 32),

                Center(
                  child: Text(
                    'Last seen details',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Text('Last seen date'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _lastSeenDateController,
                      decoration: InputDecoration(
                        hintText: '__/__/____',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text('Last seen location'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lastSeenLocationController,
                  decoration: InputDecoration(
                    hintText: 'Enter location: zone, area, city, street...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                Text('Select last seen location on map (optional)'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocationReportScreen(),
                      ),
                    );

                    if (result != null) {
                      _updateMapLocation(
                        result['latitude'],
                        result['longitude'],
                        result['address'],
                      );

                      if (_lastSeenLocationController.text.isEmpty) {
                        _lastSeenLocationController.text = _address ?? '';
                      }
                    }
                  },
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          if (_latitude != null && _longitude != null)
                            GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(_latitude!, _longitude!),
                                zoom: 15,
                              ),
                              markers: _markers,
                              onMapCreated: (GoogleMapController controller) {
                                _mapController = controller;
                              },
                              myLocationEnabled: false,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              mapToolbarEnabled: false,
                            )
                          else
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_location_alt,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to select location on map',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_latitude != null &&
                              _longitude != null &&
                              _address != null)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                color: Colors.black.withOpacity(0.6),
                                child: Text(
                                  _address!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.teal,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.edit_location_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _continueToNextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const ButtomNavBar(currentIndex: 2),
    );
  }

  Widget _buildCompletedStep() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.teal, width: 2),
      ),
      child: Center(child: Icon(Icons.check, color: AppColors.teal, size: 20)),
    );
  }

  Widget _buildActiveStep(int step) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.teal,
        border: Border.all(color: AppColors.teal, width: 2),
      ),
      child: Center(
        child: Text(
          '$step',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInactiveStep(int step) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.teal, width: 2),
      ),
      child: Center(
        child: Text(
          '$step',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.teal,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 50,
      height: 2,
      color: isActive ? AppColors.teal : Colors.grey.shade300,
    );
  }
}
