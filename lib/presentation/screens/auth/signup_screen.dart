import 'package:flutter/material.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:find_them/data/models/auth.dart';
import 'package:find_them/core/routes/navigation_helper.dart';
import 'package:find_them/core/routes/route_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_them/logic/cubits/auth/auth_cubit.dart';
import 'package:find_them/logic/cubits/auth/auth_state.dart';

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

  // Field error states
  bool _firstNameError = false;
  bool _lastNameError = false;
  bool _usernameError = false;
  bool _emailError = false;
  bool _phoneNumberError = false;
  bool _passwordError = false;
  bool _confirmPasswordError = false;

  // Field error messages
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
      // Check first name
      if (_firstNameController.text.isEmpty) {
        _firstNameError = true;
        _firstNameErrorText = 'First name is required';
        isValid = false;
      } else {
        _firstNameError = false;
        _firstNameErrorText = null;
      }

      // Check last name
      if (_lastNameController.text.isEmpty) {
        _lastNameError = true;
        _lastNameErrorText = 'Last name is required';
        isValid = false;
      } else {
        _lastNameError = false;
        _lastNameErrorText = null;
      }

      // Check username
      if (_usernameController.text.isEmpty) {
        _usernameError = true;
        _usernameErrorText = 'Username is required';
        isValid = false;
      } else {
        _usernameError = false;
        _usernameErrorText = null;
      }

      // Check email
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

      // Check phone number
      if (_completePhoneNumber.isEmpty) {
        _phoneNumberError = true;
        _phoneNumberErrorText = 'Phone number is required';
        isValid = false;
      } else {
        _phoneNumberError = false;
        _phoneNumberErrorText = null;
      }

      // Check password
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

      // Check confirm password
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
      // Form is valid, create the signup data
      final signupData = SignUpData(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        username: _usernameController.text,
        email: _emailController.text,
        phoneNumber: _completePhoneNumber,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      // Use the AuthCubit to handle signup
      context.read<AuthCubit>().signup(signupData);
      return; // Return early to prevent further validation
    }

    // Only show dialog if validation fails
    _showErrorDialog('Please fill in all required fields');
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

  void _processErrorMessage(String errorMessage) {
    errorMessage = errorMessage.toLowerCase();
    _clearAllErrors();

    setState(() {
      // Check for user-friendly version of Django REST Framework errors
      if (errorMessage.contains('username') &&
          (errorMessage.contains('already') ||
              errorMessage.contains('taken') ||
              errorMessage.contains('exists'))) {
        _usernameError = true;
        _usernameErrorText = 'Username is already taken';
        _showFieldSpecificError('Username is already taken');
      } else if (errorMessage.contains('email') &&
          (errorMessage.contains('already') ||
              errorMessage.contains('taken') ||
              errorMessage.contains('exists'))) {
        _emailError = true;
        _emailErrorText = 'Email is already in use';
        _showFieldSpecificError('Email is already in use');
      } else if (errorMessage.contains('phone') ||
          errorMessage.contains('number')) {
        _phoneNumberError = true;
        _phoneNumberErrorText = 'Invalid phone number';
        _showFieldSpecificError('Invalid phone number');
      } else if (errorMessage.contains('password')) {
        if (errorMessage.contains('match')) {
          _confirmPasswordError = true;
          _confirmPasswordErrorText = 'Passwords don\'t match';
          _showFieldSpecificError('Passwords don\'t match');
        } else if (errorMessage.contains('weak') ||
            errorMessage.contains('common') ||
            errorMessage.contains('similar') ||
            errorMessage.contains('short')) {
          _passwordError = true;
          _passwordErrorText = 'Password is too weak';
          _showFieldSpecificError(
            'Password is too weak - use a stronger password',
          );
        } else {
          _passwordError = true;
          _passwordErrorText = 'Invalid password';
          _showFieldSpecificError('Invalid password');
        }
      } else {
        // Generic error, show dialog
        _showErrorDialog(
          errorMessage.substring(0, 1).toUpperCase() +
              errorMessage.substring(1),
        );
      }
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
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.teal),
              );
            },
          );
        } else if (state is AuthError) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          _processErrorMessage(state.message);
        } else if (state is AuthAuthenticated) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          // Clear all error states
          _clearAllErrors();

          // Navigate to verification screen
          NavigationHelper.goToVerifyPhone(_completePhoneNumber);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
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
                        // Back button
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
                                  ).pushNamed(RouteConstants.login),
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
                            // First Name column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      border: _buildBorder(_firstNameError),
                                      enabledBorder: _buildBorder(
                                        _firstNameError,
                                      ),
                                      focusedBorder: _buildBorder(
                                        _firstNameError,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
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

                            // Last Name column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      border: _buildBorder(_lastNameError),
                                      enabledBorder: _buildBorder(
                                        _lastNameError,
                                      ),
                                      focusedBorder: _buildBorder(
                                        _lastNameError,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
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

                        // Username field
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
                            padding: const EdgeInsets.only(top: 4, left: 8),
                            child: Text(
                              _usernameErrorText!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Email field
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
                            // Basic email validation
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        if (_emailError && _emailErrorText != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 8),
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
                            hintStyle: const TextStyle(color: Colors.grey),
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
                          flagsButtonPadding: const EdgeInsets.only(left: 8),
                          showDropdownIcon: true,
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
                          onChanged: (phone) {
                            // Update the complete phone number when it changes
                            setState(() {
                              _completePhoneNumber = phone.completeNumber;
                              _selectedCountryCode = '+${phone.countryCode}';
                              _phoneNumberError = false;
                            });
                          },
                          onCountryChanged: (country) {
                            // Update the selected country code when it changes
                            setState(() {
                              _selectedCountryCode = '+${country.dialCode}';
                            });
                          },
                        ),
                        if (_phoneNumberError && _phoneNumberErrorText != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 8),
                            child: Text(
                              _phoneNumberErrorText!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Password field
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
                            padding: const EdgeInsets.only(top: 4, left: 8),
                            child: Text(
                              _passwordErrorText!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Confirm Password field
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
                            enabledBorder: _buildBorder(_confirmPasswordError),
                            focusedBorder: _buildBorder(_confirmPasswordError),
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
                            padding: const EdgeInsets.only(top: 4, left: 8),
                            child: Text(
                              _confirmPasswordErrorText!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Sign up button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _handleSignup,
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
      ),
    );
  }
}
