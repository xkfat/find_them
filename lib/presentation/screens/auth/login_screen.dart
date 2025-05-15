import 'package:flutter/material.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/core/routes/navigation_helper.dart';
import 'package:find_them/core/routes/route_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_them/logic/cubits/auth/auth_cubit.dart';
import 'package:find_them/logic/cubits/auth/auth_state.dart';
import 'package:find_them/data/models/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _usernameError = false;
  bool _passwordError = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AssetImage('assets/images/login.png'), context);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Error',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      setState(() {
        _isLoading = true;
      });

      context.read<AuthCubit>().login(username, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
            _usernameError = false;
            _passwordError = false;
          });
        } else if (state is AuthError) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.message;

            // Set specific error flags based on the error message
            if (state.message.toLowerCase().contains('username')) {
              _usernameError = true;
              _passwordError = false;
            } else if (state.message.toLowerCase().contains('password')) {
              _passwordError = true;
              _usernameError = false;
            } else {
              // For generic errors, highlight both fields
              _usernameError = true;
              _passwordError = true;
            }
          });
        } else if (state is AuthAuthenticated) {
          setState(() {
            _isLoading = false;
            _errorMessage = null;
          });
          NavigationHelper.goToHome();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.darkGreen,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Logo
                Image.asset('assets/images/login.png', height: 120),
                const SizedBox(height: 55),

                // Main Login Container
                Container(
                  width: 370,
                  height: 600,
                  decoration: BoxDecoration(
                    color: AppColors.lightMint,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 31),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 28),
                          // Welcome text
                          Text(
                            'Welcome back!',
                            style: GoogleFonts.lato(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Log in to access your account',
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 40),

                          // Username field
                          Container(
                            width: 308,
                            height: 84,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              border:
                                  _usernameError
                                      ? Border.all(color: Colors.red, width: 1)
                                      : null,
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                inputDecorationTheme: InputDecorationTheme(
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  border: InputBorder.none,
                                  // Remove any outline effects
                                  outlineBorder: BorderSide.none,
                                ),
                              ),
                              child: Center(
                                child: TextFormField(
                                  controller: _usernameController,
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                    hintText: 'Username',
                                    isDense: true,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        right: 8.0,
                                      ),
                                      child: Icon(
                                        Icons.person_outline,
                                        color: AppColors.darkGreen,
                                        size: 24,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 20,
                                    ),
                                  ),
                                  cursorColor: AppColors.darkGreen,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return null; // We'll handle errors with the _errorMessage
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),

                          // Username error message
                          if (_usernameError)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 16),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Wrong username',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),

                          SizedBox(height: _usernameError ? 20 : 25),
                          SizedBox(height: 10),

                          // Password field
                          Container(
                            width: 308,
                            height: 84,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              border:
                                  _passwordError
                                      ? Border.all(color: Colors.red, width: 1)
                                      : null,
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                inputDecorationTheme: InputDecorationTheme(
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  border: InputBorder.none,
                                  // Remove any outline effects
                                  outlineBorder: BorderSide.none,
                                ),
                              ),
                              child: Center(
                                child: TextFormField(
                                  controller: _passwordController,
                                  textAlignVertical: TextAlignVertical.center,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    isDense: true,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        right: 8.0,
                                      ),
                                      child: Icon(
                                        Icons.lock_outline,
                                        color: AppColors.darkGreen,
                                        size: 24,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: AppColors.darkGreen,
                                      ),
                                      onPressed: _togglePasswordVisibility,
                                    ),
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 20,
                                    ),
                                  ),
                                  cursorColor: AppColors.darkGreen,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return null; // We'll handle errors with the _errorMessage
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),

                          // Password error message
                          if (_passwordError)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 16),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Wrong password',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),

                          SizedBox(height: _passwordError ? 20 : 40),
                          // Login button

                          // Login button
                          SizedBox(
                            width: 200,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(80),
                                ),
                                elevation: 0,
                              ),
                              child:
                                  _isLoading
                                      ? CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      )
                                      : Text(
                                        'Login',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                          SizedBox(height: 25),

                          // Sign up text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black87,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => NavigationHelper.goToSignup(),
                                child: Text(
                                  'Sign up',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.teal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 54),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
