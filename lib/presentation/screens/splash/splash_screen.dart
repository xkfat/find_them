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

  startTimer() {
    var duration = Duration(seconds: 5);
    return Timer(duration, route);
  }

  route(){
    Navigator.of(context).pushReplacementNamed(RouteConstants.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Image.asset(
          'assets/images/app__logo.png',
         
        ),
      ),
    );
  }
}
