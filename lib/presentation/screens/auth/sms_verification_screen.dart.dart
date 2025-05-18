import 'dart:async';

import 'package:find_them/data/models/auth.dart';
import 'package:find_them/logic/cubit/sms_verification_cubit.dart';
import 'package:find_them/presentation/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class SmsVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final SignUpData? signUpData;

  const SmsVerificationScreen({
    Key? key,
    required this.phoneNumber,
    this.signUpData,
  }) : super(key: key);

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
  String _errorMessage = 'Wrong code, please try again';
  bool _showSuccess = false;

  Timer? _timer;
  int _timeRemaining = 150;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 4; i++) {
      _focusNodes[i].addListener(() {
        setState(() {});
      });
    }

    _sendVerificationCode();
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
      if (mounted) {
        setState(() {
          if (_timeRemaining > 0) {
            _timeRemaining--;
          } else {
            _canResend = true;
            timer.cancel();
            context.read<SmsVerificationCubit>().handleTimeout();
          }
        });
      }
    });
  }

  String get _formattedTime {
    int minutes = _timeRemaining ~/ 60;
    int seconds = _timeRemaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _sendVerificationCode() {
    context.read<SmsVerificationCubit>().sendVerificationCode(
      widget.phoneNumber,
    );
  }

  void _verifyCode() {
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      String enteredCode = _controllers.map((c) => c.text).join();

      if (widget.signUpData != null) {
        context.read<SmsVerificationCubit>().completeSignupWithVerification(
          widget.signUpData!,
          enteredCode,
        );
      } else {
        context.read<SmsVerificationCubit>().verifyCode(enteredCode);
      }
    } else {
      setState(() {
        _showError = true;
        _errorMessage = 'Please enter the complete verification code';
      });
    }
  }

  void _resendCode() {
    context.read<SmsVerificationCubit>().resendCode(widget.phoneNumber);
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
  }

  void _goBack() async {
    if (widget.signUpData != null) {
      bool? shouldDelete = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Go back to signup?'),
              content: const Text(
                'Your account was created but not verified. Going back will delete this account and you\'ll need to sign up again.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Stay here'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Go back'),
                ),
              ],
            ),
      );

      if (shouldDelete == true) {
        context.read<SmsVerificationCubit>().deleteAccount(
          widget.signUpData!.username,
        );
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SmsVerificationCubit, SmsVerificationState>(
      listener: (context, state) {
        if (state is SmsVerificationSuccess) {
          setState(() {
            _showSuccess = true;
            _showError = false;
          });
        } else if (state is SmsVerificationError) {
          setState(() {
            _showError = true;
            _errorMessage = state.error;
          });
        } else if (state is SmsVerificationCodeSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.teal,
            ),
          );
        } else if (state is SmsVerificationAccountDeleted) {
          Navigator.of(context).pop();
        } else if (state is SmsVerificationTimedOut) {
          setState(() {
            _canResend = true;
          });
        }
      },
      builder: (context, state) {
        return _showSuccess
            ? _buildSuccessScreen()
            : _buildVerificationScreen(state);
      },
    );
  }

  Widget _buildVerificationScreen(SmsVerificationState state) {
    bool isLoading =
        state is SmsVerificationLoading ||
        state is SmsVerificationAccountDeletionLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 16.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.black,
                      size: 28,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _goBack,
                  ),
                ),
                Padding(
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
                        'Please enter the 4 digit code sent to ${widget.phoneNumber}',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 40),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          4,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
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
                                    width: 1.7,
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
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      focusedErrorBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    enabled: !isLoading,
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

                      Center(
                        child:
                            _showError
                                ? Text(
                                  _errorMessage,
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
                            onPressed: isLoading ? null : _verifyCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.teal,
                              disabledBackgroundColor: AppColors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child:
                                isLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                    : Text(
                                      'Verify Code',
                                      style: GoogleFonts.inter(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Center(
                        child: Text(
                          'Code expires in $_formattedTime',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppColors.grey,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

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
                              onPressed:
                                  (_canResend && !isLoading)
                                      ? _resendCode
                                      : null,
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
                                  color:
                                      (_canResend && !isLoading)
                                          ? AppColors.teal
                                          : AppColors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (isLoading &&
              false) 
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.teal),
                ),
              ),
            ),
        ],
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
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
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
