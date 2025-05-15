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
  const SignUpOptions({super.key});

  @override
  Widget build(BuildContext context) {
    // Get access to the AuthCubit from context
    final authCubit = context.read<AuthCubit>();

    // Function to handle Google sign in
    void handleGoogleSignIn() async {
      Navigator.pop(context); // Close the bottom sheet
      // Google sign-in will be handled by BlocListener
      authCubit.signInWithGoogle();
    }

    // Function to handle Facebook sign in
    void handleFacebookSignIn() async {
      Navigator.pop(context); // Close the bottom sheet
      // Facebook sign-in will be handled by BlocListener
      authCubit.signInWithFacebook();
    }

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate to home screen and clear the navigation stack
          NavigationHelper.navigateAndClearStack(RouteConstants.home);
        } else if (state is AuthError) {
          // Show error message in a SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Stack(
        children: [
          // The main draggable sheet
          DraggableScrollableSheet(
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
                              Navigator.of(
                                context,
                              ).pushNamed(RouteConstants.signup);
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
                              Navigator.of(
                                context,
                              ).pushNamed(RouteConstants.login);
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
                                onPressed: handleFacebookSignIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1877F2),
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
          ),

          // Loading indicator overlay that appears when AuthLoading state is active
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const CircularProgressIndicator(
                        color: AppColors.teal,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink(); // Return empty widget when not loading
            },
          ),
        ],
      ),
    );
  }
}
