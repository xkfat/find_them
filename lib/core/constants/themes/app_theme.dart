import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.teal,
      scaffoldBackgroundColor: AppColors.backgroundGrey,
      cardColor: AppColors.white,
      dividerColor: AppColors.lightgrey,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundGrey,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: false,
      ),
      
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.black),
        bodyMedium: TextStyle(color: AppColors.black),
        titleLarge: TextStyle(color: AppColors.black),
        titleMedium: TextStyle(color: AppColors.black),
        titleSmall: TextStyle(color: AppColors.darkGreen),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.lighterMint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkGreen, width: 1),
        ),
      ),
      
      iconTheme: const IconThemeData(color: AppColors.black),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: AppColors.white,
        ),
      ),
      
      colorScheme: const ColorScheme.light(
        primary: AppColors.teal,
        secondary: AppColors.darkGreen,
        surface: AppColors.white,
        error: AppColors.missingRed,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.black,
        onError: AppColors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.teal,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkCardBackground,
      dividerColor: AppColors.darkDivider,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
        bodyMedium: TextStyle(color: AppColors.darkTextPrimary),
        titleLarge: TextStyle(color: AppColors.darkTextPrimary),
        titleMedium: TextStyle(color: AppColors.darkTextPrimary),
        titleSmall: TextStyle(color: AppColors.darkTextSecondary),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.darkCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkDivider, width: 1),
        ),
      ),
      
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: AppColors.white,
        ),
      ),
      
      colorScheme: const ColorScheme.dark(
        primary: AppColors.teal,
        secondary: AppColors.darkGreen,
        surface: AppColors.darkSurface,
        error: AppColors.missingRedDark,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.white,
      ),
    );
  }
}