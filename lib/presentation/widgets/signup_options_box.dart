import 'package:find_them/core/routes/route_constants.dart';
import 'package:find_them/core/routes/navigation_helper.dart';
import 'package:find_them/logic/cubits/auth/auth_state.dart';
import 'package:find_them/logic/cubits/auth/auth_cubit.dart';
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
    final scaffoldContext = context;

    final authCubit = BlocProvider.of<AuthCubit>(context);

    void handleGoogleSignIn() async {
      try {
        Navigator.pop(scaffoldContext); // Close the bottom sheet

        _showLoadingDialog(scaffoldContext);

        authCubit.signInWithGoogle();
      } catch (e) {
        print("Error in handleGoogleSignIn: $e");
        if (scaffoldContext.mounted) {
          _showErrorDialog(scaffoldContext, "Google sign-in failed: $e");
        }
      }
    }

    void handleFacebookSignIn() async {
      try {
        Navigator.pop(scaffoldContext); // Close the bottom sheet

        _showLoadingDialog(scaffoldContext);

        authCubit.signInWithFacebook();
      } catch (e) {
        print("Error in handleFacebookSignIn: $e");
        if (scaffoldContext.mounted) {
          _showErrorDialog(scaffoldContext, "Facebook sign-in failed: $e");
        }
      }
    }

    return /*BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        print("Current AuthState: ${state.runtimeType}");

        // Only proceed if the context is still valid
        if (!context.mounted) return;

        // Close loading dialog if open
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        if (state is AuthAuthenticated) {
          print("AuthAuthenticated state received - navigating to home");
          NavigationHelper.navigateAndClearStack(RouteConstants.home);
        } else if (state is AuthSignupSuccessful) {
          print(
            "AuthSignupSuccessful state received - navigating to verification",
          );
          final phoneNumber = state.phoneNumber;
          NavigationHelper.goToVerifyPhone(phoneNumber);
        } else if (state is AuthError) {
          print("AuthError state received: ${state.message}");
          // Show error dialog
          _showErrorDialog(context, state.message);
        }
      },
      
      child:
      */ DraggableScrollableSheet(
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
                            onPressed: () => Navigator.pop(context),
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
                      onPressed: () {
                        Navigator.of(context).pushNamed(RouteConstants.signup);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
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
                      onPressed: () {
                        Navigator.of(context).pushNamed(RouteConstants.login);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
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
                        child: Divider(color: AppColors.white, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        child: Divider(color: AppColors.white, thickness: 1),
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
                          onPressed: handleFacebookSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1877F2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                          onPressed: handleGoogleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
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
                                  color: AppColors.black,
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
    );
  }

  void _showLoadingDialog(BuildContext context) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
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
                const CircularProgressIndicator(color: AppColors.teal),
                const SizedBox(height: 16),
                Text(
                  'Signing you in...',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
