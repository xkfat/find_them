import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

class AppTheme {
  static ThemeData get lightTheme => LightTheme.theme;
  static ThemeData get darkTheme => DarkTheme.theme;

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'missing':
      case 'active':
        return AppColors.missingRed;
      case 'investigating':
      case 'in progress':
        return AppColors.investigatingYellow;
      case 'found':
      case 'closed':
        return AppColors.foundGreen;
      default:
        return AppColors.grey;
    }
  }

  static Color getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'missing':
      case 'active':
        return AppColors.missingRedBackground;
      case 'investigating':
      case 'in progress':
        return AppColors.investigatingYellowBackground;
      case 'found':
      case 'closed':
        return AppColors.foundGreenBackground;
      default:
        return AppColors.white;
    }
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
