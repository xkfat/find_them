import 'package:flutter/material.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/presentation/widgets/bottom_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'dart:io';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'dart:developer';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _completePhoneNumber = '';
  String _selectedCountryCode = '+222';

  File? _profileImage;
  final _imagePicker = ImagePicker();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // data from repository
    _loadUserData();
  }

  void _loadUserData() {
    // repository to fetch data
    _firstNameController.text = 'Itunuoluwa';
    _lastNameController.text = 'Abidoye';
    _usernameController.text = 'Itunuoluwa@petra.africa';
    _emailController.text = 'Itunuoluwa@petra.africa';
    _phoneController.text = '12345678';
    _completePhoneNumber = '$_selectedCountryCode$_phoneController.text';
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

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      log('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _updateProfile() {
    setState(() {
      _isLoading = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: AppColors.teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.darkGreen,
                      backgroundImage:
                          _profileImage != null
                              ? FileImage(_profileImage!)
                              : AssetImage('assets/images/profile.png')
                                  as ImageProvider,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.teal),
                      ),
                      child: Icon(Icons.edit, size: 16, color: AppColors.teal),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                '${_firstNameController.text} ${_lastNameController.text}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                _emailController.text,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              Text(
                _phoneController.text,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 32),

              _buildTextField('Update your first name', _firstNameController),

              const SizedBox(height: 16),

              _buildTextField('Update your last name', _lastNameController),

              const SizedBox(height: 16),

              _buildTextField('Update your username here', _usernameController),

              const SizedBox(height: 16),

              const SizedBox(height: 8),
              IntlPhoneField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: '12345678',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                initialCountryCode: 'MR',
                dropdownIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.darkGreen,
                ),
                flagsButtonPadding: const EdgeInsets.only(left: 8),
                showDropdownIcon: true,
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

              const SizedBox(height: 16),

              _buildTextField(
                'Update your email here',
                _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    disabledBackgroundColor: AppColors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
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
      bottomNavigationBar: const ButtomNavBar(currentIndex: 4),
    );
  }

  Widget _buildTextField(
    String hintText,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
