import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/data/repositories/auth_repo.dart';
import 'package:find_them/data/services/auth_service.dart';
import 'package:flutter/material.dart';
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
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      final authRepository = AuthRepository(AuthService());
      final isLoggedIn = await authRepository.isLoggedIn();

      if (!mounted) return;

      if (isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        if (mounted) route();
      }
    } catch (e) {
      if (mounted) {}
    }
  }

  Future<void> startTimer() async {
    Timer(const Duration(milliseconds: 3600), () {
      route();
    });
    await Future.delayed(const Duration(seconds: 1));
  }

  route() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.teal,
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pushReplacementNamed('/onboarding');
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Image.asset('assets/images/app__logo.png')],
          ),
        ),
      ),
    );
  }
}
