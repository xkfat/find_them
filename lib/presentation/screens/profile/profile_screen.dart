import 'dart:developer';

import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/logic/cubit/profile_cubit.dart';
import 'package:find_them/presentation/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'dart:io';
import 'package:find_them/data/models/user.dart';
import 'package:google_fonts/google_fonts.dart';

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
  File? _profileImage;
  final _imagePicker = ImagePicker();

  bool _isUserDataLoaded = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            _loadUserData(state.user);
            setState(() {
              _isUserDataLoaded = true;
              _currentUser = state.user;
            });
          } else if (state is ProfileUpdateError) {
            if (state.user != null) {
              _loadUserData(state.user!);
              setState(() {
                _currentUser = state.user;
              });
            }
          } else if (state is ProfilePhotoUploadSuccess) {
            setState(() {
              _profileImage = null;
              _currentUser = state.user;
            });
            _loadUserData(state.user);
          } else if (state is ProfilePhotoUploadError) {
            if (state.user != null) {
              setState(() {
                _currentUser = state.user;
              });
            }
          }
        },
        builder: (context, state) {
          User? user;
          bool isLoadingProfileData = false;
          bool isUpdatingProfile = false;
          bool isUploadingPhoto = false;

          if (state is ProfileLoaded) {
            user = state.user;
          } else if (state is ProfileUpdateSuccess) {
            user = state.user;
          } else if (state is ProfilePhotoUploadSuccess) {
            user = state.user;
          } else if (state is ProfileUpdateError && state.user != null) {
            user = state.user;
          } else if (state is ProfilePhotoUploadError && state.user != null) {
            user = state.user;
          }

          if (state is ProfileLoading) {
            isLoadingProfileData = true;
          }
          if (state is ProfileUpdating) {
            isUpdatingProfile = true;
          }
          if (state is ProfilePhotoUploading) {
            isUploadingPhoto = true;
          }

          if (user != null) {
            _currentUser = user;
            if (!_isUserDataLoaded) {
              _loadUserData(user);
              _isUserDataLoaded = true;
            }
          }

          if (user == null && isLoadingProfileData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (user == null) {
            if (_currentUser != null) {
              user = _currentUser;
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state is ProfileLoadError
                          ? 'Error: ${state.message}'
                          : 'No profile data to display. Please try again.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileCubit>().loadProfile();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  user != null
                      ? _buildUserInfoContainer(user, isUploadingPhoto)
                      : const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 30),
                  _buildFormFields(),
                  const SizedBox(height: 40),
                  _buildUpdateButton(isUpdatingProfile || isUploadingPhoto),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(left: 0),
        child: ButtomNavBar(currentIndex: 4),
      ),
    );
  }

  Widget _buildUserInfoContainer(User user, bool isUploadingPhoto) {
    return Center(
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileImageSection(user, isUploadingPhoto),
            const SizedBox(height: 20),
            Text(
              "${user.firstName} ${user.lastName}",
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              user.email,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
              textAlign: TextAlign.center,
            ),
            if (user.phoneNumber.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                user.phoneNumber,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection(User? user, bool isUploadingPhoto) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          backgroundImage:
              _getProfileImage(user) ??
              const AssetImage('assets/images/profile.png'),
          child:
              _getProfileImage(user) == null && !isUploadingPhoto
                  ? (user?.profilePhoto == null || user!.profilePhoto!.isEmpty
                      ? null
                      : const Icon(Icons.person, size: 50, color: Colors.white))
                  : null,
        ),
        if (isUploadingPhoto)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: isUploadingPhoto ? null : _pickAndUploadImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.teal, width: 2),
              ),
              child:
                  isUploadingPhoto
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.teal,
                          strokeWidth: 2,
                        ),
                      )
                      : const Icon(Icons.edit, color: AppColors.teal, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildValidatedInputField(
                'First Name',
                _firstNameController,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 2) {
                    return 'First name must be at least 2 characters';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildValidatedInputField(
                'Last Name',
                _lastNameController,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 2) {
                    return 'Last name must be at least 2 characters';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildValidatedInputField(
          'Username',
          _usernameController,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (value.length < 3) {
                return 'Username must be at least 3 characters';
              }
              if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(value)) {
                return 'Username can only contain letters, numbers, underscores, or dots.';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildPhoneField(),
        const SizedBox(height: 20),
        _buildValidatedInputField(
          'Email',
          _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildUpdateButton(bool isAnyUpdating) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isAnyUpdating ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child:
            isAnyUpdating
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
    );
  }

  ImageProvider? _getProfileImage(User? user) {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    } else if (user != null &&
        user.profilePhoto != null &&
        user.profilePhoto!.isNotEmpty) {
      return NetworkImage(user.profilePhoto!);
    }
    return null;
  }

  void _loadUserData(User user) {
    if (_firstNameController.text != user.firstName) {
      _firstNameController.text = user.firstName;
    }
    if (_lastNameController.text != user.lastName) {
      _lastNameController.text = user.lastName;
    }
    if (_usernameController.text != user.username) {
      _usernameController.text = user.username;
    }
    if (_emailController.text != user.email) {
      _emailController.text = user.email;
    }

    _completePhoneNumber = user.phoneNumber;

    if (user.phoneNumber.isEmpty) {
      _phoneController.text = '';
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final selectedImage = File(pickedFile.path);
        setState(() => _profileImage = selectedImage);
        await context.read<ProfileCubit>().uploadProfilePhoto(selectedImage);
      }
    } catch (e) {
      log('Error picking image: ${e.toString()}');
    }
  }

  void _updateProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileCubit>().updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _completePhoneNumber,
      );
    }
  }

  Widget _buildValidatedInputField(
    String hintText,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool isReadOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: isReadOnly,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.teal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }

  Widget _buildPhoneField() {
    return IntlPhoneField(
      initialValue: _currentUser?.phoneNumber,
      controller: _phoneController,
      decoration: InputDecoration(
        hintText: 'Phone Number',
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.teal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      initialCountryCode: 'MR',
      onChanged: (phone) {
        _completePhoneNumber = phone.completeNumber;
      },
      validator: (phoneNumber) {
        if (phoneNumber != null && phoneNumber.number.isNotEmpty) {
          if (!RegExp(r'^[0-9]+$').hasMatch(phoneNumber.number)) {
            return 'Phone number must contain only digits';
          }
        }
        return null;
      },
    );
  }
}
