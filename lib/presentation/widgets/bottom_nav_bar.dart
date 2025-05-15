import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NavIcons {
  static final IconData home = PhosphorIcons.house();
  static final IconData homeBold = PhosphorIcons.house(PhosphorIconsStyle.bold);
  static final IconData map = PhosphorIcons.mapTrifold();
  static final IconData mapBold = PhosphorIcons.mapTrifold(
    PhosphorIconsStyle.bold,
  );
  static final IconData report = PhosphorIcons.plusCircle();
  static final IconData reportBold = PhosphorIcons.plusCircle(
    PhosphorIconsStyle.bold,
  );
  static final IconData settings = PhosphorIcons.gear();
  static final IconData settingsBold = PhosphorIcons.gear(
    PhosphorIconsStyle.bold,
  );
  static final IconData profile = PhosphorIcons.userCircle();
  static final IconData profileBold = PhosphorIcons.userCircle(
    PhosphorIconsStyle.bold,
  );
}

class ButtomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ButtomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define navigation items
    final List<_NavItem> navItems = [
      _NavItem(
        // Removed const since we're using non-const icons
        label: 'Home',
        icon: NavIcons.home,
        boldIcon: NavIcons.homeBold,
      ),
      _NavItem(label: 'Map', icon: NavIcons.map, boldIcon: NavIcons.mapBold),
      _NavItem(
        label: 'Report',
        icon: NavIcons.report,
        boldIcon: NavIcons.reportBold,
      ),
      _NavItem(
        label: 'Settings',
        icon: NavIcons.settings,
        boldIcon: NavIcons.settingsBold,
      ),
      _NavItem(
        label: 'Profile',
        icon: NavIcons.profile,
        boldIcon: NavIcons.profileBold,
      ),
    ];

    return Material(
      color: AppColors.lightMint,
      elevation: 8,
      child: SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isActive = index == currentIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? item.boldIcon : item.icon,
                        size: 24,
                        color: isActive ? AppColors.darkGreen : AppColors.teal,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                          color:
                              isActive ? AppColors.darkGreen : AppColors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/*

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(navItems.length, (index) {
            final item = navItems[index];
            final isActive = index == currentIndex;
            
            return InkWell(
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive ? item.boldIcon : item.icon,
                    size: 24,
                    color: isActive ? AppColors.darkGreen : AppColors.teal,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: GoogleFonts.rubik(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? AppColors.darkGreen : AppColors.teal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}



*/
// Simple class to hold navigation item data
class _NavItem {
  final String label;
  final IconData icon;
  final IconData boldIcon;

  const _NavItem({
    // Now using const constructor
    required this.label,
    required this.icon,
    required this.boldIcon,
  });
}
