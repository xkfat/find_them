import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/cupertino.dart';

class ButtomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ButtomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lighterMint,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black, blurRadius: 5, spreadRadius: 1),
        ],
      ),

      child: Material(
        color: Colors.transparent,
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.darkGreen,
          unselectedItemColor: AppColors.teal,
          selectedLabelStyle: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 2,
          ),
          unselectedLabelStyle: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 2,
          ),
          currentIndex: currentIndex,
          onTap: onTap,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/house-line.png',
                width: 35,
                height: 35,
                color: AppColors.teal,
              ),

              activeIcon: Image.asset(
                'assets/icons/house-line-fill.png',
                width: 35,
                height: 35,
                color: AppColors.darkGreen,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/map.png',
                width: 35,
                height: 35,
                color: AppColors.teal,
              ),
              activeIcon: Image.asset(
                'assets/icons/mapFill.png',
                width: 35,
                height: 35,
                color: AppColors.darkGreen,
              ),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline, size: 35),
              activeIcon: Icon(Icons.add_circle, size: 35),
              label: 'Report',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined, size: 35),
              activeIcon: Icon(Icons.settings, size: 35),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/user-circle.png',
                width: 35,
                height: 35,
                color: AppColors.darkGreen,
              ),
              activeIcon: Image.asset(
                'assets/icons/user-circle-fill.png',
                width: 35,
                height: 35,
                color: AppColors.darkGreen,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
