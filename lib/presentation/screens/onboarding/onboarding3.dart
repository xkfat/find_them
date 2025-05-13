import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/themes/app_colors.dart';

class Onboarding3Screen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const Onboarding3Screen({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 42),

        // Image
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 41),
          child: Image.asset(
            'assets/images/onboarding3.png',
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 60),

        // Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 41),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.roboto(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.2,
              ),
              children: [
                TextSpan(
                  text: 'Join our community',
                  style: GoogleFonts.roboto(color: AppColors.teal),
                ),
                const TextSpan(text: ' to make a difference.'),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Get Started Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
          child: ElevatedButton(
            onPressed: onGetStarted,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}
