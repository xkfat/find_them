import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF3D8D7F),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3D8D7F),
      secondary: const Color(0xFF1C4B43),
    ),
    scaffoldBackgroundColor: Color(0xFFF4F4F4),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF3D8D7F),
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3D8D7F),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFF3D8D7F)),
    ),
  );
}
