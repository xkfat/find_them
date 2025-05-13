import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/themes/app_colors.dart';
import 'onboarding1.dart';
import 'onboarding2.dart';
import 'onboarding3.dart';
import '../../widgets/signup_options_box.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _skipToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignUpOptions()),
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _skipToSignUp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.only(top: 16, right: 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _skipToSignUp,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),

            // PageView for onboarding screens
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: const [
                  Onboarding1Screen(),
                  Onboarding2Screen(),
                  Onboarding3Screen(),
                ],
              ),
            ),

            // Page indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFF064A3E) // darkGreen
                        : const Color(0xFFD1D1D1), // grey
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}