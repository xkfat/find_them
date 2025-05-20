import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/presentation/screens/report/report_screen3.dart';
import 'package:find_them/presentation/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  //LatLng? _selectedLocation;

  @override
  void dispose() {
    _lastSeenDateController.dispose();
    _lastSeenLocationController.dispose();
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
        ).showSnackBar(SnackBar(content: Text('Please select a date')));
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => Report3Screen(
                firstName: widget.firstName,
                lastName: widget.lastName,
                age: widget.age,
                gender: widget.gender,
                lastSeenDate: _selectedDate!,
                lastSeenLocation: _lastSeenLocationController.text,
                //locationCoordinates: _selectedLocation,
              ),
        ),
      );
    }
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
                        suffixIcon: Icon(Icons.calendar_today),
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
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Center(child: Text('Google map view')),
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
