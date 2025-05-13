import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/themes/app_colors.dart';
import 'onboarding2.dart';
import '../../widgets/signup_options_box.dart';

class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, right: 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 42),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 41),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    image: DecorationImage(
                      image: AssetImage('assets/images/onboarding1.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 60),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.darkGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
