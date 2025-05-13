import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../core/routes/route_constants.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    startTimer();
    super.initState();
  }

  Future<void> startTimer() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  route() {
    Navigator.of(context).pushReplacementNamed(RouteConstants.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.teal,
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pushReplacementNamed(RouteConstants.onboarding);
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/app__logo.png'),
            ],
          ),
        ),
      ),
    );
  }
}
