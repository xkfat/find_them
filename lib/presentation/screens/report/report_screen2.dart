import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/presentation/screens/report/location_report_screen.dart';
import 'package:find_them/presentation/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:find_them/presentation/helpers/localisation_extenstion.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.pleaseSelectDate),
            backgroundColor: Colors.red,
          ),
        );
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

  void _handleLocationResult(Map<String, dynamic> result) {
    setState(() {
      _latitude = result['latitude'];
      _longitude = result['longitude'];
      _lastSeenLocationController.text = result['humanReadableLocation'];
    });
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
          infoWindow: InfoWindow(
            title: context.l10n.lastSeenLocationLabel.replaceAll(':', ''),
            snippet: addr,
          ),
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getSurfaceColor(context),
      appBar: AppBar(
        title: Text(
          context.l10n.reportingMissingPerson,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.getTextColor(context),
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.getSurfaceColor(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.getTextColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        // CHANGE 1: Column instead of SingleChildScrollView
        children: [
          // CHANGE 2: Wrap content in Expanded + SingleChildScrollView
          Expanded(
            child: SingleChildScrollView(
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
                          _buildStepCircle(1, false, isCompleted: true),
                          _buildStepLine(true),
                          _buildStepCircle(2, true),
                          _buildStepLine(false),
                          _buildStepCircle(3, false),
                        ],
                      ),
                      const SizedBox(height: 32),

                      Center(
                        child: Text(
                          context.l10n.lastSeenDetails,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      Text(
                        context.l10n.lastSeenDate,
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _lastSeenDateController,
                            decoration: InputDecoration(
                              hintText: '__/__/____',
                              filled: true,
                              fillColor: AppColors.getSurfaceColor(context),
                              hintStyle: TextStyle(
                                color: AppColors.getSecondaryTextColor(context),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.getDividerColor(context),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.getDividerColor(context),
                                ),
                              ),
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: AppColors.getTextColor(context),
                              ),
                            ),
                            style: TextStyle(
                              color: AppColors.getTextColor(context),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context.l10n.pleaseSelectDate;
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        context.l10n.lastSeenLocation,
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _lastSeenLocationController,
                        decoration: InputDecoration(
                          hintText: context.l10n.enterLocation,
                          filled: true,
                          fillColor: AppColors.getSurfaceColor(context),
                          hintStyle: TextStyle(
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.getDividerColor(context),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.getDividerColor(context),
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.pleaseEnterLocation;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      Text(
                        context.l10n.selectLocationOnMap,
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const LocationReportScreen(),
                            ),
                          );

                          if (result != null) {
                            _handleLocationResult(result);
                            _updateMapLocation(
                              result['latitude'],
                              result['longitude'],
                              result['humanReadableLocation'],
                            );

                            if (_lastSeenLocationController.text.isEmpty) {
                              _lastSeenLocationController.text =
                                  result['humanReadableLocation'];
                            }
                          }
                        },
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.getDividerColor(context),
                            ),
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
                                    onMapCreated: (
                                      GoogleMapController controller,
                                    ) {
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_location_alt,
                                          size: 40,
                                          color:
                                              AppColors.getSecondaryTextColor(
                                                context,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          context.l10n.tapToSelectLocation,
                                          style: TextStyle(
                                            color:
                                                AppColors.getSecondaryTextColor(
                                                  context,
                                                ),
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
                                      color: Colors.black,
                                      child: Text(
                                        _address!,
                                        style: TextStyle(
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

                      // CHANGE 3: Add extra bottom padding for scroll clearance
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // CHANGE 4: NEW - Fixed button area at bottom
          Container(
            padding: const EdgeInsets.fromLTRB(
              16,
              20,
              16,
              100,
            ), // More bottom padding
            color: AppColors.getSurfaceColor(
              context,
            ), // Simple color, no shadow
            child: Center(
              child: SizedBox(
                width: 248,
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
                    context.l10n.continueLabel,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 0),
        child: ButtomNavBar(currentIndex: 2),
      ),
    );
  }

  Widget _buildStepCircle(int step, bool isActive, {bool isCompleted = false}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isActive || isCompleted
                ? AppColors.teal
                : AppColors.getSurfaceColor(context),
        border: Border.all(color: AppColors.teal, width: 2),
      ),
      child: Center(
        child:
            isCompleted
                ? Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                  '$step',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : AppColors.teal,
                  ),
                ),
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 50,
      height: 2,
      color: isActive ? AppColors.teal : AppColors.getDividerColor(context),
    );
  }
}
