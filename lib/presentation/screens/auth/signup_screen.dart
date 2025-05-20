import 'dart:convert';

import 'package:find_them/logic/cubit/sign_up_cubit.dart';
import 'package:find_them/presentation/screens/auth/sms_verification_screen.dart.dart';
import 'package:flutter/material.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:find_them/data/models/auth.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCountryCode = '+222';
  String _completePhoneNumber = '';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _firstNameError = false;
  bool _lastNameError = false;
  bool _usernameError = false;
  bool _emailError = false;
  bool _phoneNumberError = false;
  bool _passwordError = false;
  bool _confirmPasswordError = false;

  String? _firstNameErrorText;
  String? _lastNameErrorText;
  String? _usernameErrorText;
  String? _emailErrorText;
  String? _phoneNumberErrorText;
  String? _passwordErrorText;
  String? _confirmPasswordErrorText;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 40),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(100, 30),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFieldSpecificError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _validateAllFields() {
    bool isValid = true;

    setState(() {
      if (_firstNameController.text.isEmpty) {
        _firstNameError = true;
        _firstNameErrorText = 'First name is required';
        isValid = false;
      } else {
        _firstNameError = false;
        _firstNameErrorText = null;
      }

      if (_lastNameController.text.isEmpty) {
        _lastNameError = true;
        _lastNameErrorText = 'Last name is required';
        isValid = false;
      } else {
        _lastNameError = false;
        _lastNameErrorText = null;
      }

      if (_usernameController.text.isEmpty) {
        _usernameError = true;
        _usernameErrorText = 'Username is required';
        isValid = false;
      } else {
        _usernameError = false;
        _usernameErrorText = null;
      }

      if (_emailController.text.isEmpty) {
        _emailError = true;
        _emailErrorText = 'Email is required';
        isValid = false;
      } else if (!_emailController.text.contains('@') ||
          !_emailController.text.contains('.')) {
        _emailError = true;
        _emailErrorText = 'Please enter a valid email address';
        isValid = false;
      } else {
        _emailError = false;
        _emailErrorText = null;
      }

      if (_completePhoneNumber.isEmpty) {
        _phoneNumberError = true;
        _phoneNumberErrorText = 'Phone number is required';
        isValid = false;
      } else {
        _phoneNumberError = false;
        _phoneNumberErrorText = null;
      }

      if (_passwordController.text.isEmpty) {
        _passwordError = true;
        _passwordErrorText = 'Password is required';
        isValid = false;
      } else if (_passwordController.text.length < 6) {
        _passwordError = true;
        _passwordErrorText = 'Password must be at least 6 characters';
        isValid = false;
      } else {
        _passwordError = false;
        _passwordErrorText = null;
      }

      if (_confirmPasswordController.text.isEmpty) {
        _confirmPasswordError = true;
        _confirmPasswordErrorText = 'Please confirm your password';
        isValid = false;
      } else if (_confirmPasswordController.text != _passwordController.text) {
        _confirmPasswordError = true;
        _confirmPasswordErrorText = 'Passwords do not match';
        isValid = false;
      } else {
        _confirmPasswordError = false;
        _confirmPasswordErrorText = null;
      }
    });

    return isValid;
  }

  void _handleSignup() {
    if (_validateAllFields() && _formKey.currentState!.validate()) {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final phoneNumber = _completePhoneNumber;
      final password = _passwordController.text;
      final passwordConfirmation = _confirmPasswordController.text;

      _clearAllErrors();

      context.read<SignUpCubit>().signup(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    } else {
      List<String> errorMessages = [];
      if (_firstNameError && _firstNameErrorText != null) {
        errorMessages.add(_firstNameErrorText!);
      }
      if (_lastNameError && _lastNameErrorText != null) {
        errorMessages.add(_lastNameErrorText!);
      }
      if (_usernameError && _usernameErrorText != null) {
        errorMessages.add(_usernameErrorText!);
      }
      if (_emailError && _emailErrorText != null) {
        errorMessages.add(_emailErrorText!);
      }
      if (_phoneNumberError && _phoneNumberErrorText != null) {
        errorMessages.add(_phoneNumberErrorText!);
      }
      if (_passwordError && _passwordErrorText != null) {
        errorMessages.add(_passwordErrorText!);
      }
      if (_confirmPasswordError && _confirmPasswordErrorText != null) {
        errorMessages.add(_confirmPasswordErrorText!);
      }

      if (errorMessages.isNotEmpty) {
        _showErrorDialog(errorMessages.join('\n'));
      } else {
        _showErrorDialog('Please fill in all required fields correctly');
      }
    }
  }

  void _clearAllErrors() {
    setState(() {
      _firstNameError = false;
      _lastNameError = false;
      _usernameError = false;
      _emailError = false;
      _phoneNumberError = false;
      _passwordError = false;
      _confirmPasswordError = false;

      _firstNameErrorText = null;
      _lastNameErrorText = null;
      _usernameErrorText = null;
      _emailErrorText = null;
      _phoneNumberErrorText = null;
      _passwordErrorText = null;
      _confirmPasswordErrorText = null;
    });
  }

  void _handleFieldError(String field, String message) {
    setState(() {
      _clearAllErrors(); 

      switch (field.toLowerCase()) {
        case 'username':
          _usernameError = true;
          _usernameErrorText = message;
          break;

        case 'email':
          _emailError = true;
          _emailErrorText = message;
          break;

        case 'phone':
        case 'phone_number':
        case 'phonenumber':
          _phoneNumberError = true;
          _phoneNumberErrorText = message;
          break;

        case 'password':
          _passwordError = true;
          _passwordErrorText = message;
          break;

        case 'confirm_password':
        case 'confirmpassword':
          _confirmPasswordError = true;
          _confirmPasswordErrorText = message;
          break;

        case 'first_name':
        case 'firstname':
          _firstNameError = true;
          _firstNameErrorText = message;
          break;

        case 'last_name':
        case 'lastname':
          _lastNameError = true;
          _lastNameErrorText = message;
          break;

        default:
          _showErrorDialog(message);
          break;
      }
    });
  }

  void _processErrorMessage(String errorMessage) {
    _clearAllErrors();

    Map<String, dynamic> errorMap = {};

    try {
      if (errorMessage.contains('{') && errorMessage.contains('}')) {
        final jsonStart = errorMessage.indexOf('{');
        final jsonEnd = errorMessage.lastIndexOf('}') + 1;
        final jsonStr = errorMessage.substring(jsonStart, jsonEnd);
        errorMap = json.decode(jsonStr);
      }
    } catch (e) {
      print("Error parsing JSON: $e");
    }

    setState(() {
      if (errorMessage.toLowerCase().contains('username') &&
          (errorMessage.toLowerCase().contains('already') ||
              errorMessage.toLowerCase().contains('taken'))) {
        _usernameError = true;
        _usernameErrorText = 'Username is already taken';
        _showFieldSpecificError('Username is already taken');
        return;
      }

      if (errorMessage.toLowerCase().contains('email')) {
        if (errorMessage.toLowerCase().contains('already') ||
            errorMessage.toLowerCase().contains('taken')) {
          _emailError = true;
          _emailErrorText = 'Email is already in use';
          _showFieldSpecificError('Email is already in use');
          return;
        } else if (errorMessage.toLowerCase().contains('valid')) {
          _emailError = true;
          _emailErrorText = 'Please enter a valid email address';
          _showFieldSpecificError('Please enter a valid email address');
          return;
        }
      }

      if (errorMessage.toLowerCase().contains('phone')) {
        _phoneNumberError = true;
        _phoneNumberErrorText = 'Invalid phone number format';
        _showFieldSpecificError('Please enter a valid phone number');
        return;
      }

      if (errorMessage.toLowerCase().contains('password')) {
        if (errorMessage.toLowerCase().contains('match')) {
          _confirmPasswordError = true;
          _confirmPasswordErrorText = 'Passwords do not match';
          _showFieldSpecificError('Passwords do not match');
          return;
        } else if (errorMessage.toLowerCase().contains('characters') ||
            errorMessage.toLowerCase().contains('short')) {
          _passwordError = true;
          _passwordErrorText = 'Password must be at least 6 characters';
          _showFieldSpecificError('Password must be at least 6 characters');
          return;
        } else if (errorMessage.toLowerCase().contains('common') ||
            errorMessage.toLowerCase().contains('weak')) {
          _passwordError = true;
          _passwordErrorText = 'Password is too weak or too common';
          _showFieldSpecificError('Please use a stronger password');
          return;
        }
      }

      _showErrorDialog(
        errorMessage.substring(0, 1).toUpperCase() + errorMessage.substring(1),
      );
    });
  }

  OutlineInputBorder _buildBorder(bool hasError) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide:
          hasError
              ? BorderSide(color: Colors.red, width: 1.0)
              : BorderSide.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state is SignUploaded) {
          final params = {
            'phoneNumber': _completePhoneNumber,
            'signUpData': SignUpData(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              username: _usernameController.text.trim(),
              email: _emailController.text.trim(),
              phoneNumber: _completePhoneNumber,
              password: _passwordController.text,
              passwordConfirmation: _confirmPasswordController.text,
            ),
          };
          Navigator.of(
            context,
          ).pushNamed('/auth/verify-phone', arguments: params);
        } else if (state is SignUpFieldError) {
          _handleFieldError(state.field, state.message);
        } else if (state is SignUperreur) {
          _showErrorDialog(state.msg);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.95,
                        maxHeight: 1200,
                      ),
                      margin: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightMint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  size: 24.0,
                                  color: AppColors.darkGreen,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => Navigator.pop(context),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                'Sign up',
                                style: GoogleFonts.inter(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  const Text('Already have an account? '),
                                  GestureDetector(
                                    onTap:
                                        () => Navigator.of(
                                          context,
                                        ).pushNamed('/auth/login'),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.teal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'First Name',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.darkGreen,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _firstNameController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 16,
                                                ),
                                            border: _buildBorder(
                                              _firstNameError,
                                            ),
                                            enabledBorder: _buildBorder(
                                              _firstNameError,
                                            ),
                                            focusedBorder: _buildBorder(
                                              _firstNameError,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter your first name';
                                            }
                                            return null;
                                          },
                                        ),
                                        if (_firstNameError &&
                                            _firstNameErrorText != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                              left: 8,
                                            ),
                                            child: Text(
                                              _firstNameErrorText!,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Last Name',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.darkGreen,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _lastNameController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 16,
                                                ),
                                            border: _buildBorder(
                                              _lastNameError,
                                            ),
                                            enabledBorder: _buildBorder(
                                              _lastNameError,
                                            ),
                                            focusedBorder: _buildBorder(
                                              _lastNameError,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter your last name';
                                            }
                                            return null;
                                          },
                                        ),
                                        if (_lastNameError &&
                                            _lastNameErrorText != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                              left: 8,
                                            ),
                                            child: Text(
                                              _lastNameErrorText!,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              const Text(
                                'Username',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  hintText: 'Enter a username',
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  border: _buildBorder(_usernameError),
                                  enabledBorder: _buildBorder(_usernameError),
                                  focusedBorder: _buildBorder(_usernameError),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a username';
                                  }
                                  return null;
                                },
                              ),
                              if (_usernameError && _usernameErrorText != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 8,
                                  ),
                                  child: Text(
                                    _usernameErrorText!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 16),

                              const Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'Enter your email address',
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  border: _buildBorder(_emailError),
                                  enabledBorder: _buildBorder(_emailError),
                                  focusedBorder: _buildBorder(_emailError),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@') ||
                                      !value.contains('.')) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              if (_emailError && _emailErrorText != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 8,
                                  ),
                                  child: Text(
                                    _emailErrorText!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 16),

                              const Text(
                                'Phone Number',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              const SizedBox(height: 8),
                              IntlPhoneField(
                                decoration: InputDecoration(
                                  hintText: '12345678',
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide:
                                        _phoneNumberError
                                            ? BorderSide(
                                              color: Colors.red,
                                              width: 1.0,
                                            )
                                            : BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide:
                                        _phoneNumberError
                                            ? BorderSide(
                                              color: Colors.red,
                                              width: 1.0,
                                            )
                                            : BorderSide.none,
                                  ),
                                ),
                                initialCountryCode: 'MR',
                                dropdownIcon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.darkGreen,
                                ),
                                flagsButtonPadding: const EdgeInsets.only(
                                  left: 8,
                                ),
                                showDropdownIcon: true,
                                validator: (phone) {
                                  if (phone != null &&
                                      phone.number.isNotEmpty) {
                                    if (!RegExp(
                                      r'^[0-9]+$',
                                    ).hasMatch(phone.number)) {
                                      return 'Phone number should contain only digits.';
                                    }
                                  }
                                  return null;
                                },
                                pickerDialogStyle: PickerDialogStyle(
                                  searchFieldInputDecoration:
                                      const InputDecoration(
                                        hintText: 'Search country',
                                        prefixIcon: Icon(Icons.search),
                                      ),
                                  backgroundColor: Colors.white,
                                  listTilePadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                onChanged: (phone) {
                                  setState(() {
                                    _completePhoneNumber = phone.completeNumber;
                                    _selectedCountryCode =
                                        '+${phone.countryCode}';
                                    _phoneNumberError = false;
                                  });
                                },
                                onCountryChanged: (country) {
                                  setState(() {
                                    _selectedCountryCode =
                                        '+${country.dialCode}';
                                  });
                                },
                              ),
                              if (_phoneNumberError &&
                                  _phoneNumberErrorText != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 8,
                                  ),
                                  child: Text(
                                    _phoneNumberErrorText!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 16),

                              const Text(
                                'Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  border: _buildBorder(_passwordError),
                                  enabledBorder: _buildBorder(_passwordError),
                                  focusedBorder: _buildBorder(_passwordError),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                      size: 22,
                                    ),
                                    onPressed: _togglePasswordVisibility,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              if (_passwordError && _passwordErrorText != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 8,
                                  ),
                                  child: Text(
                                    _passwordErrorText!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              const Text(
                                'Confirm Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  border: _buildBorder(_confirmPasswordError),
                                  enabledBorder: _buildBorder(
                                    _confirmPasswordError,
                                  ),
                                  focusedBorder: _buildBorder(
                                    _confirmPasswordError,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                      size: 22,
                                    ),
                                    onPressed: _toggleConfirmPasswordVisibility,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              if (_confirmPasswordError &&
                                  _confirmPasswordErrorText != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 8,
                                  ),
                                  child: Text(
                                    _confirmPasswordErrorText!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed:
                                      state is SignUpLoading
                                          ? null
                                          : _handleSignup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.darkGreen,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
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
                ),
              ),
              if (state is SignUpLoading)
                Center(child: CircularProgressIndicator(color: AppColors.teal)),
            ],
          ),
        );
      },
    );
  }
}
