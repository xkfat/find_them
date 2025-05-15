import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/core/routes/navigation_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class SmsVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool showError;

  const SmsVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.showError = false,
  });

  @override
  State<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _showError = false;
  bool _showSuccess = false;

  Timer? _timer;
  int _timeRemaining = 150;
  bool _canResend = true;

  @override
  void initState() {
    super.initState();
    _showError = widget.showError;

    // Set up focus node listeners
    for (int i = 0; i < 4; i++) {
      _focusNodes[i].addListener(() {
        setState(() {});
      });
    }
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();

    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _timeRemaining = 150;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String get _formattedTime {
    int minutes = _timeRemaining ~/ 60;
    int seconds = _timeRemaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _verifyCode() {
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      String enteredCode = _controllers.map((c) => c.text).join();

      if (enteredCode == "1234") {
        setState(() {
          _showSuccess = true;
          _showError = false;
        });
      } else {
        setState(() {
          _showError = true;
          _showSuccess = false;
        });
      }
    }
  }

  void _resendCode() {
    _startTimer();
    for (var controller in _controllers) {
      controller.clear();
    }
    if (_controllers.isNotEmpty && _focusNodes.isNotEmpty) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    }
    setState(() {
      _showError = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code resent'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black, size: 40),
          onPressed: () => NavigationHelper.goBack(),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Enter code',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Please enter the 4 digit code sent to your phone number',
              style: GoogleFonts.roboto(fontSize: 18, color: AppColors.black),
            ),
            const SizedBox(height: 40),

            // Code input
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                    width: 71,
                    height: 71,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              _showError
                                  ? Colors.red
                                  : (_focusNodes[index].hasFocus
                                      ? AppColors.teal
                                      : AppColors.grey),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: TextFormField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color:
                                _showError
                                    ? AppColors.missingRed
                                    : AppColors.darkGrey,
                          ),
                          maxLength: 1,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 3) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_focusNodes[index + 1]);
                            }

                            if (_showError) {
                              setState(() {
                                _showError = false;
                              });
                            }

                            if (index == 3 && value.isNotEmpty) {
                              if (_controllers.every(
                                (c) => c.text.isNotEmpty,
                              )) {
                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () {
                                    _verifyCode();
                                  },
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 26),

            // Show error message or expiry timer based on error state
            Center(
              child:
                  _showError
                      ? Text(
                        'Wrong code, please try again',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      )
                      : const SizedBox.shrink(),
            ),

            const SizedBox(height: 50),

            Center(
              child: SizedBox(
                width: 362,
                height: 72,
                child: ElevatedButton(
                  onPressed: _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(
                    'Verify Code',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Timer display - moved beneath the Verify button
            Center(
              child: Text(
                'Code expires in $_formattedTime',
                style: GoogleFonts.inter(fontSize: 16, color: AppColors.grey),
              ),
            ),

            const SizedBox(height: 12),

            // Resend option
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "I didn't receive a code",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _canResend ? _resendCode : null,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Resend",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _canResend ? AppColors.teal : AppColors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.teal,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Success!',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Congratulations! You have been successfully authenticated',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 16, color: AppColors.grey),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 320,
              height: 56,
              child: ElevatedButton(
                onPressed: () => NavigationHelper.goToHome(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
