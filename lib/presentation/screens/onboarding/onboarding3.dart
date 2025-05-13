import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/themes/app_colors.dart';
import '../../widgets/signup_options_box.dart';

class Onboarding3Screen extends StatelessWidget {
  const Onboarding3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Back button
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
                  style: GoogleFonts.roboto(
                    color: AppColors.teal,
                  ),
                ),
                const TextSpan(
                  text: ' to make a difference.',
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Get Started Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SignUpOptions()),
              );
            },
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}