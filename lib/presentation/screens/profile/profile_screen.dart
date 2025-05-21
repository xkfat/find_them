import 'package:flutter/material.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/presentation/widgets/bottom_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'dart:io';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_them/data/models/user.dart';
import 'package:find_them/logic/cubit/profile_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _completePhoneNumber = '';
  String _selectedCountryCode = '+234'; // Nigeria code

  File? _profileImage;
  final _imagePicker = ImagePicker();

  // Field error tracking
  Map<String, String> _fieldErrors = {};

  // Local state management
  bool _isLoading = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    // Delay the loadProfile call to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  // Get the ProfileCubit instance
  ProfileCubit _getProfileCubit() {
    return context.read<ProfileCubit>();
  }

  // Load profile and register a listener for state changes
  void _loadProfile() {
    final cubit = _getProfileCubit();

    // Load the profile
    cubit.loadProfile();

    // Setup a stream subscription to listen for state changes
    cubit.stream.listen((state) {
      if (state is ProfileLoaded) {
        setState(() {
          _isLoading = false;
          _user = state.user;
          _loadUserData(state.user);
          _fieldErrors.clear();
        });
      } else if (state is ProfileLoading) {
        setState(() {
          _isLoading = true;
        });
      } else if (state is ProfileUpdateSuccess) {
        setState(() {
          _isLoading = false;
          _user = state.user;
          _loadUserData(state.user);
          _fieldErrors.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.teal,
          ),
        );
      } else if (state is ProfileUpdateError) {
        setState(() {
          _isLoading = false;
          _fieldErrors = state.fieldErrors;
        });

        if (state.fieldErrors.isEmpty && state.message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      } else if (state is ProfileUpdating) {
        setState(() {
          _isLoading = true;
        });
      }
    });
  }

  void _loadUserData(User user) {
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _usernameController.text = user.username;
    _emailController.text = user.email;

    // Extract phone number without country code
    final phoneNumber = user.phoneNumber;
    if (phoneNumber.isNotEmpty) {
      // Basic parsing - improve this based on your phone format
      if (phoneNumber.startsWith('+')) {
        int digitIndex = 0;
        for (int i = 1; i < phoneNumber.length; i++) {
          if (phoneNumber[i] == ' ' || phoneNumber[i] == '-') {
            digitIndex = i + 1;
            break;
          }
        }
        if (digitIndex > 0) {
          _selectedCountryCode = phoneNumber.substring(0, digitIndex).trim();
          _phoneController.text = phoneNumber.substring(digitIndex);
        } else {
          _phoneController.text = phoneNumber;
        }
      } else {
        _phoneController.text = phoneNumber;
      }
    }

    _completePhoneNumber = phoneNumber;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Function to handle profile photo upload separately from other profile updates
  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
          _isLoading = true; // Show loading state while uploading
        });

        // Upload immediately after picking
        try {
          // Use the updateProfile method but only pass the profilePhoto
          _getProfileCubit().updateProfile(
            firstName: _user?.firstName ?? "",
            lastName: _user?.lastName ?? "",
            username: _user?.username ?? "",
            email: _user?.email ?? "",
            phoneNumber: _user?.phoneNumber ?? "",
            profilePhoto: _profileImage,
          );

          // The state updates are handled by the cubit listener we set up in _loadProfile
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile photo: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      log('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  // Function to update profile data (excluding photo)
  void _updateProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      _getProfileCubit().updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _completePhoneNumber,
        profilePhoto: null, // Don't update photo here
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF9F9F9,
      ), // Light grey background from image
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
      ),
      body:
          _isLoading && _user == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Image with Edit Button
                        Center(
                          child: Stack(
                            children: [
                              // Profile Image
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: AppColors.darkGreen,
                                backgroundImage: _getProfileImage(),
                                child:
                                    !_hasProfileImage()
                                        ? const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.white,
                                        )
                                        : null,
                              ),

                              // Edit button
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap:
                                      _pickAndUploadImage, // Upload immediately on tap
                                  child: Container(
                                    height: 28,
                                    width: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.darkGreen,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: AppColors.darkGreen,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ), // Space between photo and name
                        // User Full Name
                        if (_user != null)
                          Text(
                            "${_user!.firstName} ${_user!.lastName}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                        // Email (username)
                        if (_user != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _user!.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),

                        // Phone Number
                        if (_user != null && _user!.phoneNumber.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _user!.phoneNumber,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),

                        const SizedBox(height: 20), // Space before form fields
                        // First Name and Last Name Row
                        Row(
                          children: [
                            // First Name Field
                            Expanded(
                              child: _buildInputField(
                                'Update your first name',
                                _firstNameController,
                                errorText: _fieldErrors['first_name'],
                              ),
                            ),
                            const SizedBox(width: 10), // Space between fields
                            // Last Name Field
                            Expanded(
                              child: _buildInputField(
                                'Update your last name',
                                _lastNameController,
                                errorText: _fieldErrors['last_name'],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 40,
                        ), // Space between form sections
                        // Username Field
                        _buildInputField(
                          'Update your username here',
                          _usernameController,
                          errorText: _fieldErrors['username'],
                        ),

                        const SizedBox(
                          height: 40,
                        ), // Space between form sections
                        // Phone Field
                        _buildPhoneField(
                          errorText: _fieldErrors['phone_number'],
                        ),

                        const SizedBox(
                          height: 40,
                        ), // Space between form sections
                        // Email Field
                        _buildInputField(
                          'Update your email here',
                          _emailController,
                          keyboardType: TextInputType.emailAddress,
                          errorText: _fieldErrors['email'],
                        ),

                        const SizedBox(height: 40), // Space before button
                        // Update Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.teal,
                              disabledBackgroundColor: AppColors.teal
                                  .withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  25,
                                ), // Rounded corners
                              ),
                              elevation: 0, // No shadow
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text(
                                      'Update Profile',
                                      style: TextStyle(
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
      bottomNavigationBar: const ButtomNavBar(currentIndex: 4),
    );
  }

  // Helper method to check if profile image exists
  bool _hasProfileImage() {
    return _profileImage != null ||
        (_user != null &&
            _user!.profilePhoto != null &&
            _user!.profilePhoto!.isNotEmpty);
  }

  // Helper method to get profile image
  ImageProvider? _getProfileImage() {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    } else if (_user != null &&
        _user!.profilePhoto != null &&
        _user!.profilePhoto!.isNotEmpty) {
      return NetworkImage(_user!.profilePhoto!);
    } else {
      return const AssetImage('assets/images/profile.png');
    }
  }

  Widget _buildInputField(
    String hintText,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25), // Rounded corners
            border: Border.all(
              color: hasError ? Colors.red : Colors.grey.shade300,
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPhoneField({String? errorText}) {
    final hasError = errorText != null && errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25), // Rounded corners
            border: Border.all(
              color: hasError ? Colors.red : Colors.grey.shade300,
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: IntlPhoneField(
            controller: _phoneController,
            decoration: InputDecoration(
              hintText: 'Phone number',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              filled: false, // No fill color
              border: InputBorder.none, // No visible border
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            initialCountryCode: 'NG', // Nigeria
            dropdownIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            flagsButtonPadding: const EdgeInsets.only(left: 15),
            showDropdownIcon: true,
            disableLengthCheck: true, // Don't check phone number length
            onChanged: (phone) {
              setState(() {
                _completePhoneNumber = phone.completeNumber;
                _selectedCountryCode = '+${phone.countryCode}';
              });
            },
            onCountryChanged: (country) {
              setState(() {
                _selectedCountryCode = '+${country.dialCode}';
              });
            },
            pickerDialogStyle: PickerDialogStyle(
              searchFieldInputDecoration: const InputDecoration(
                hintText: 'Search country',
                prefixIcon: Icon(Icons.search),
              ),
              backgroundColor: Colors.white,
              listTilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
