import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/core/routes/navigation_helper.dart';
import 'package:find_them/logic/cubits/auth/auth_cubit.dart';
import 'package:find_them/logic/cubits/auth/auth_state.dart';
import 'dart:async';

class SmsVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const SmsVerificationScreen({Key? key, required this.phoneNumber})
    : super(key: key);

  @override
  State<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _resendSeconds = 60;
  Timer? _timer;
  String? _verificationId = 'simulated-verification-id';

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    for (int i = 0; i < 4; i++) {
      _focusNodes[i].addListener(() {
        setState(() {});
      });
    }
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

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() {
          _resendSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _resendCode() {
    if (_resendSeconds == 0) {
      context.read<AuthCubit>().resendVerificationSms(widget.phoneNumber);
      setState(() {
        _resendSeconds = 60;
      });
      _startResendTimer();
    }
  }

  void _verifyCode() {
    final code = _controllers.map((c) => c.text).join();

    if (code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 4-digit code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AuthCubit>().verifySmsCode(_verificationId!, code);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSmsCodeSent) {
          _verificationId = state.verificationId;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification code sent successfully'),
              backgroundColor: AppColors.teal,
            ),
          );
        } else if (state is AuthAuthenticated) {
          NavigationHelper.goToHome();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone verified successfully'),
              backgroundColor: AppColors.teal,
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final bool isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.lightMint,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: InkWell(
                        onTap: () => NavigationHelper.goBack(),
                        borderRadius: BorderRadius.circular(50),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 24,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Enter code',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Please enter the 4 digit code sent to your phone number',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        4,
                        (index) => SizedBox(
                          width: 70,
                          height: 70,
                          child: TextFormField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.teal,
                                  width: 2,
                                ),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 3) {
                                FocusScope.of(
                                  context,
                                ).requestFocus(_focusNodes[index + 1]);
                              }

                              if (index == 3 && value.isNotEmpty) {
                                bool allFilled = _controllers.every(
                                  (c) => c.text.isNotEmpty,
                                );
                                if (allFilled) {
                                  FocusScope.of(context).unfocus();
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

                    const SizedBox(height: 16),

                    Center(
                      child: Text(
                        'Code expires in 2:30',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _verifyCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          disabledBackgroundColor: AppColors.teal.withOpacity(
                            0.5,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text(
                                  'Verify Code',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "I didn't receive a code  ",
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        GestureDetector(
                          onTap: _resendCode,
                          child: Text(
                            "Resend",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
