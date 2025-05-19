import 'package:find_them/presentation/screens/home/home_screen.dart';
import 'package:find_them/presentation/screens/report/report_screen.dart';
import 'package:find_them/presentation/screens/report/report_screen2.dart';
import 'package:find_them/presentation/screens/report/report_screen3.dart';
import 'package:find_them/presentation/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';

class NavHandler {
  static void handleNavTap(BuildContext context, int index) {
    bool isHomeScreen = context.widget is HomeScreen;
    bool isReportScreen =
        context.widget is Report1Screen || context.widget is Report2Screen
    ||
     context.widget is Report3Screen;

    bool isMapScreen = false;
    bool isSettingsScreen = false;
    bool isProfileScreen = false;

    switch (index) {
      case 0:
        if (!isHomeScreen) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        break;

      // case 1:

      /*
        if (!isMapScreen) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => MapScreen()));
        }
        break;
*/
      case 2:
        if (!isReportScreen) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => Report1Screen()));
        }
        break;

      case 3:
      if (!isProfileScreen) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => ProfileScreen()));
        }
        break;


      //case 4:
    }
  }
}
