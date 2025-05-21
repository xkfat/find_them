
import 'package:flutter/material.dart';

class NavHandler {
  static void handleNavTap(BuildContext context, int index) {
    String? currentRoute = ModalRoute.of(context)?.settings.name;

    switch (index) {
      case 0: 
        if (currentRoute != '/home') {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (route) => false);
        }
        break;

      case 1: 
        if (currentRoute != '/map') {
          Navigator.of(context).pushNamed('/map');
        }
        break;

      case 2: 
        Navigator.of(context).pushNamed('/report');
        break;

      case 3: 
        if (currentRoute != '/settings') {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/settings', (route) => false);
        }
        break;

      case 4: 
        if (currentRoute != '/profile') {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/profile', (route) => false);
        }
        break;
    }
  }
}
