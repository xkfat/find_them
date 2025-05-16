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

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 41),
          child: Image.asset(
            'assets/images/onboarding2.png',
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 60),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 41),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.roboto(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
                height: 1.1,
              ),
              children: [
                TextSpan(
                  text: 'Together',
                  style: GoogleFonts.roboto(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w800,
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
