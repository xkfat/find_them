import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/themes/app_colors.dart';

class Onboarding1Screen extends StatelessWidget {
  final VoidCallback onNextPage;

  const Onboarding1Screen({super.key, required this.onNextPage});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 42),

        // Image
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 41),
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.teal,
                image: DecorationImage(
                  image: AssetImage('assets/images/onboarding1.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 50),

        // Text content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 41),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to',
                style: GoogleFonts.roboto(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                  height: 1.1,
                ),
              ),
              Row(
                children: [
                  Text(
                    'FindThem',
                    style: GoogleFonts.roboto(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: AppColors.teal,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    ',',
                    style: GoogleFonts.roboto(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              Text(
                'where hope exists!',
                style: GoogleFonts.roboto(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),
      ],
    );
  }
}
