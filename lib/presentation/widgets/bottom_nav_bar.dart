import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/core/routes/nav_handler.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:find_them/presentation/helpers/localisation_extenstion.dart';

class ButtomNavBar extends StatelessWidget {
  final int currentIndex;

  const ButtomNavBar({super.key, required this.currentIndex});

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
          onTap: (index) => NavHandler.handleNavTap(context, index),
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
              label: context.l10n.home,
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
              label: context.l10n.map,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline, size: 35),
              activeIcon: Icon(Icons.add_circle, size: 35),
              label: context.l10n.report,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined, size: 35),
              activeIcon: Icon(Icons.settings, size: 35),
              label: context.l10n.settings,
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
              label: context.l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}
