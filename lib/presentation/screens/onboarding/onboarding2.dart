import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/themes/app_colors.dart';

class Onboarding2Screen extends StatelessWidget {
  const Onboarding2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 42),

        // Image
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 41),
          child: Image.asset(
            'assets/images/onboarding2.png',
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
                  text: 'Together',
                  style: GoogleFonts.roboto(
                    color: AppColors.teal,
                  ),
                ),
                const TextSpan(
                  text: ', we can bring missing loved ones back home.',
                ),
              ],
            ),
          ),
        ),

        const Spacer(),
      ],
    );
  }
}