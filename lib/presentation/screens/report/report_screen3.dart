import 'dart:developer';

import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/logic/cubit/submit_case_cubit.dart';
import 'package:find_them/presentation/screens/report/report_success_screen.dart';
import 'package:find_them/presentation/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Report3Screen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final int age;
  final String gender;
  final DateTime lastSeenDate;
  final String lastSeenLocation;
  final String? contactPhone;
  final double? latitude;
  final double? longitude;

  const Report3Screen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.gender,
    required this.lastSeenDate,
    required this.lastSeenLocation,
    this.contactPhone,
    this.latitude,
    this.longitude,
  });

  @override
  State<Report3Screen> createState() => _Report3ScreenState();
}

class _Report3ScreenState extends State<Report3Screen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  final _imagePicker = ImagePicker();
  bool _isSubmitting = false;
  bool _showPhotoError = false;

  @override
  void initState() {
    super.initState();
    if (widget.contactPhone != null && widget.contactPhone!.isNotEmpty) {
      _phoneController.text = widget.contactPhone!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _showPhotoError = false;
        });
      }
    } catch (e) {
      log('Error picking image: $e');
    }
  }

  void _submitReport() {
    bool isFormValid = _formKey.currentState?.validate() ?? false;

    if (_selectedImage == null) {
      setState(() {
        _showPhotoError = true;
      });
      isFormValid = false;
    } else {
      setState(() {
        _showPhotoError = false;
      });
    }

    if (isFormValid) {
      context.read<SubmitCaseCubit>().submitCase(
        widget.firstName,
        widget.lastName,
        widget.age,
        widget.gender,
        _selectedImage!,
        _descriptionController.text,
        widget.lastSeenDate,
        widget.lastSeenLocation,
        _phoneController.text,
        widget.latitude,
        widget.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getSurfaceColor(context),
      appBar: AppBar(
        title: Text(
          'Reporting a missing person',
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
      body: BlocListener<SubmitCaseCubit, SubmitCaseState>(
        listener: (context, state) {
          if (state is SubmitCaseLoading) {
            setState(() {
              _isSubmitting = true;
            });
          } else if (state is SubmitCaseLoaded) {
            setState(() {
              _isSubmitting = false;
            });

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ReportSuccessScreen()),
              (route) => false,
            );
          } else if (state is SubmitCaseError) {
            setState(() {
              _isSubmitting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
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
                      _buildStepCircle(2, false, isCompleted: true),
                      _buildStepLine(true),
                      _buildStepCircle(3, true),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Center(
                    child: Text(
                      'Additional information',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Photo',
                    style: TextStyle(color: AppColors.getTextColor(context)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _showPhotoError ? Colors.red : AppColors.teal,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: _pickImage,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.teal,
                          ),
                          child: Text(
                            'Choose photo',
                            style: TextStyle(color: AppColors.teal),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _selectedImage != null
                                ? _selectedImage!.path.split('/').last
                                : 'No photo Chosen',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.getTextColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_showPhotoError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                      child: Text(
                        'Please select a photo',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 24),

                  Text(
                    'Contact phone number',
                    style: TextStyle(color: AppColors.getTextColor(context)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Enter your phone number',
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
                    style: TextStyle(color: AppColors.getTextColor(context)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Description',
                    style: TextStyle(color: AppColors.getTextColor(context)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          'Provide details about circumstances of disappearance, clothing , etc.',
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
                    style: TextStyle(color: AppColors.getTextColor(context)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  Center(
                    child: SizedBox(
                      width: 248,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isSubmitting
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  'Submit report',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
