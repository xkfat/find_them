
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/themes/app_colors.dart';

class Onboarding2Screen extends StatelessWidget {
  const Onboarding2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Back button (visible on second screen)
        Padding(
          padding: const EdgeInsets.only(left: 24, top: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 16,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

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