import 'dart:developer';

import 'package:find_them/data/repositories/social_auth_repo.dart';
import 'package:find_them/data/services/social_auth_service.dart';
import 'package:find_them/logic/cubit/social_auth_cubit.dart';
import 'package:find_them/presentation/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/themes/app_colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpOptions extends StatelessWidget {
  final bool fromSkip;

  const SignUpOptions({super.key, this.fromSkip = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              SocialAuthCubit(SocialAuthRepository(SocialAuthService())),
      child: _SignUpOptionsContent(fromSkip: fromSkip),
    );
  }
}

class _SignUpOptionsContent extends StatefulWidget {
  final bool fromSkip;

  const _SignUpOptionsContent({required this.fromSkip});

  @override
  State<_SignUpOptionsContent> createState() => _SignUpOptionsContentState();
}

class _SignUpOptionsContentState extends State<_SignUpOptionsContent>
    with WidgetsBindingObserver {
  bool _isLoading = false;
  bool _isAuthInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("🔄 App lifecycle state changed: $state");

    if ((state == AppLifecycleState.resumed ||
            state == AppLifecycleState.inactive) &&
        _isAuthInProgress) {
      log("📱 App state change - ensuring loading overlay is visible");
      if (mounted && !_isLoading) {
        setState(() => _isLoading = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void handleGoogleSignIn() async {
      if (_isLoading || _isAuthInProgress) return;

      try {
        log("🚀 Starting Google Sign In process...");

        setState(() {
          _isLoading = true;
          _isAuthInProgress = true;
        });

        await Future.delayed(const Duration(milliseconds: 100));

        context.read<SocialAuthCubit>().signInWithGoogle();
      } catch (e) {
        log("❌ Error in handleGoogleSignIn: $e");
        setState(() {
          _isLoading = false;
          _isAuthInProgress = false;
        });
        if (context.mounted) {
          _showErrorDialog(context, "Google sign-in failed: $e");
        }
      }
    }

    void handleFacebookSignIn() async {
      if (_isLoading || _isAuthInProgress) return;

      try {
        log("🚀 Starting Facebook Sign In process...");

        setState(() {
          _isLoading = true;
          _isAuthInProgress = true;
        });

        await Future.delayed(const Duration(milliseconds: 100));

        context.read<SocialAuthCubit>().signInWithFacebook();
      } catch (e) {
        log("❌ Error in handleFacebookSignIn: $e");
        setState(() {
          _isLoading = false;
          _isAuthInProgress = false;
        });
        if (context.mounted) {
          _showErrorDialog(context, "Facebook sign-in failed: $e");
        }
      }
    }

    return Stack(
      children: [
        BlocListener<SocialAuthCubit, SocialAuthState>(
          listener: (context, state) {
            log(
              "🔥 BlocListener - Current SocialAuthState: ${state.runtimeType}",
            );

            if (state is SocialAuthSuccess) {
              log("✅ BlocListener - Authentication successful!");

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  try {
                    log("🚀 Attempting navigation to /home");

                    final navigator = Navigator.of(
                      context,
                      rootNavigator: true,
                    );

                    navigator.pushNamedAndRemoveUntil(
                      '/home',
                      (route) => false,
                    );

                    log("✅ Navigation to /home completed successfully");
                  } catch (e, stackTrace) {
                    log("❌ Navigation error: $e");
                    log("❌ Stack trace: $stackTrace");

                    try {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/', (route) => false);
                      log("✅ Fallback navigation to root completed");
                    } catch (fallbackError) {
                      log("❌ Fallback navigation also failed: $fallbackError");
                      setState(() {
                        _isLoading = false;
                        _isAuthInProgress = false;
                      });
                      _showErrorDialog(
                        context,
                        "Navigation failed. Please restart the app.",
                      );
                    }
                  }
                }
              });
            } else if (state is SocialAuthError) {
              log("❌ BlocListener - SocialAuthError: ${state.message}");
              setState(() {
                _isLoading = false;
                _isAuthInProgress = false;
              });
              _showErrorDialog(context, state.message);
            }
          },
          child: DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.7,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(34, 16, 34, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Spacer(),
                            Container(
                              width: 50,
                              height: 5,
                              decoration: BoxDecoration(
                                color: AppColors.darkGreen,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(
                                    PhosphorIcons.xCircle(),
                                    color: AppColors.darkGreen,
                                  ),
                                  onPressed:
                                      _isLoading
                                          ? null
                                          : () => Navigator.pop(context),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Login or sign up',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 13),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 75),
                        child: Text(
                          'Please select your preferred method\nto continue setting up your account',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 31),
                        child: SizedBox(
                          width: 350,
                          height: 54,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () {
                                      Navigator.of(
                                        context,
                                      ).pushNamed('/auth/signup');
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isLoading
                                      ? Colors.grey
                                      : AppColors.darkGreen,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Sign up',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 31),
                        child: SizedBox(
                          width: 350,
                          height: 54,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () {
                                      Navigator.of(
                                        context,
                                      ).pushNamed('/auth/login');
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isLoading ? Colors.grey : AppColors.teal,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Log in',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: AppColors.white,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'Or',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: AppColors.white,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 31),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 350,
                              height: 54,
                              child: ElevatedButton(
                                onPressed:
                                    _isLoading ? null : handleFacebookSignIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _isLoading
                                          ? Colors.grey
                                          : const Color(0xFF1877F2),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 36),
                                    Image.asset(
                                      'assets/icons/facebook.png',
                                      height: 24,
                                      width: 24,
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      'Continue with Facebook',
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            SizedBox(
                              width: 350,
                              height: 54,
                              child: ElevatedButton(
                                onPressed:
                                    _isLoading ? null : handleGoogleSignIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _isLoading
                                          ? Colors.grey[200]
                                          : Colors.white,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 36),
                                    Image.asset('assets/icons/google.png'),
                                    const SizedBox(width: 15),
                                    Text(
                                      'Continue with Google',
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _isLoading
                                                ? Colors.grey
                                                : AppColors.black,
                                      ),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        if (_isLoading)
          Positioned.fill(
            child: Material(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Container(
                  width: 200,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          color: AppColors.teal,
                          strokeWidth: 4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Signing you in...',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please wait',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Authentication Error',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
