import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  
  
  static TextStyle get headingLargeLight => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: bold,
    color: AppColors.darkGrey,
    letterSpacing: -0.5,
  );
  
  static TextStyle get headingMediumLight => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: bold,
    color: AppColors.darkGrey,
    letterSpacing: -0.5,
  );
  
  static TextStyle get headingSmallLight => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: bold,
    color: AppColors.darkGrey,
  );
  
  static TextStyle get titleLargeLight => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: semiBold,
    color: AppColors.darkGrey,
  );
  
  static TextStyle get titleMediumLight => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: semiBold,
    color: AppColors.darkGrey,
  );
  
  static TextStyle get titleSmallLight => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: semiBold,
    color: AppColors.darkGrey,
  );
  
  static TextStyle get bodyLargeLight => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: regular,
    color: AppColors.darkGrey,
  );
  
  static TextStyle get bodyMediumLight => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: regular,
    color: AppColors.darkGrey,
  );
  
  static TextStyle get bodySmallLight => GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: regular,
    color: AppColors.darkGrey,
  );
  
  static TextStyle get labelLargeLight => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: medium,
    color: AppColors.darkGreen,
  );
  
  static TextStyle get labelMediumLight => GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: medium,
    color: AppColors.darkGreen,
  );
  
  static TextStyle get labelSmallLight => GoogleFonts.roboto(
    fontSize: 11,
    fontWeight: medium,
    color: AppColors.darkGreen,
  );
  
  static TextStyle get buttonLargeLight => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: medium,
    color: AppColors.white,
    letterSpacing: 0.5,
  );
  
  static TextStyle get buttonMediumLight => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: medium,
    color: AppColors.white,
    letterSpacing: 0.5,
  );
  
  static TextStyle get buttonSmallLight => GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: medium,
    color: AppColors.white,
    letterSpacing: 0.5,
  );
  
  
  static TextStyle get headingLargeDark => GoogleFonts.dmSans(
    fontSize: 28,
    fontWeight: bold,
    color: AppColors.darkTextPrimary,
    letterSpacing: -0.5,
  );
  
  static TextStyle get headingMediumDark => GoogleFonts.dmSans(
    fontSize: 24,
    fontWeight: bold,
    color: AppColors.darkTextPrimary,
    letterSpacing: -0.5,
  );
  
  static TextStyle get headingSmallDark => GoogleFonts.dmSans(
    fontSize: 20,
    fontWeight: bold,
    color: AppColors.darkTextPrimary,
  );
  
  static TextStyle get titleLargeDark => GoogleFonts.dmSans(
    fontSize: 18,
    fontWeight: semiBold,
    color: AppColors.darkTextPrimary,
  );
  
  static TextStyle get titleMediumDark => GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: semiBold,
    color: AppColors.darkTextPrimary,
  );
  
  static TextStyle get titleSmallDark => GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: semiBold,
    color: AppColors.darkTextPrimary,
  );
  
  static TextStyle get bodyLargeDark => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: regular,
    color: AppColors.darkTextPrimary,
  );
  
  static TextStyle get bodyMediumDark => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: regular,
    color: AppColors.darkTextPrimary,
  );
  
  static TextStyle get bodySmallDark => GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: regular,
    color: AppColors.darkTextSecondary,
  );
  
  static TextStyle get labelLargeDark => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: medium,
    color: AppColors.teal,
  );
  
  static TextStyle get labelMediumDark => GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: medium,
    color: AppColors.teal,
  );
  
  static TextStyle get labelSmallDark => GoogleFonts.roboto(
    fontSize: 11,
    fontWeight: medium,
    color: AppColors.teal,
  );
  
  static TextStyle get buttonLargeDark => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: medium,
    color: AppColors.darkTextPrimary,
    letterSpacing: 0.5,
  );
  
  static TextStyle get buttonMediumDark => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: medium,
    color: AppColors.darkTextPrimary,
    letterSpacing: 0.5,
  );
  
  static TextStyle get buttonSmallDark => GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: medium,
    color: AppColors.darkTextPrimary,
    letterSpacing: 0.5,
  );
  
  static TextStyle getStyle(BuildContext context, {
    required TextStyle lightStyle,
    required TextStyle darkStyle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkStyle : lightStyle;
  }
  
  static TextStyle headingLarge(BuildContext context) {
    return getStyle(
      context, 
      lightStyle: headingLargeLight, 
      darkStyle: headingLargeDark
    );
  }
  
  static TextStyle headingMedium(BuildContext context) {
    return getStyle(
      context, 
      lightStyle: headingMediumLight, 
      darkStyle: headingMediumDark
    );
  }
  
  static TextStyle headingSmall(BuildContext context) {
    return getStyle(
      context, 
      lightStyle: headingSmallLight, 
      darkStyle: headingSmallDark
    );
  }
  
  static TextStyle titleLarge(BuildContext context) {
    return getStyle(
      context, 
      lightStyle: titleLargeLight, 
      darkStyle: titleLargeDark
    );
  }
  
  static TextStyle titleMedium(BuildContext context) {
    return getStyle(
      context, 
      lightStyle: titleMediumLight, 
      darkStyle: titleMediumDark
    );
  }
  
  static TextStyle titleSmall(BuildContext context) {
    return getStyle(
      context, 
      lightStyle: titleSmallLight, 
      darkStyle: titleSmallDark
    );
  }
  
  static TextStyle bodyLarge(BuildContext context) {
    return getStyle(
      context, 
      lightStyle: bodyLargeLight, 
      darkStyle: bodyLargeDark
    );
  }
  
  static TextStyle bodyMedium(BuildContext context) {
    return getStyle(
      context, 
      lightStyle: bodyMediumLight, 
      darkStyle: bodyMediumDark
    );
  }
  
  static TextStyle bodySmall(BuildContext context) {
    return getStyle(
      context, 
      lightStyle: bodySmallLight, 
      darkStyle: bodySmallDark
    );
  }
  
  static TextStyle labelLarge(BuildContext context) {
    return getStyle(
      context, 
      lightStyle: labelLargeLight, 
      darkStyle: labelLargeDark
    );
  }
  
  static TextStyle labelMedium(BuildContext context) {
    return getStyle(
      context, 
      lightStyle: labelMediumLight, 
      darkStyle: labelMediumDark
    );
  }
  
  static TextStyle labelSmall(BuildContext context) {
    return getStyle(
      context, 
      lightStyle: labelSmallLight, 
      darkStyle: labelSmallDark
    );
  }
  
  static TextStyle buttonLarge(BuildContext context) {
    return getStyle(
      context, 
      lightStyle: buttonLargeLight, 
      darkStyle: buttonLargeDark
    );
  }
  
  static TextStyle buttonMedium(BuildContext context) {
    return getStyle(
      context, 
      lightStyle: buttonMediumLight, 
      darkStyle: buttonMediumDark
    );
  }
  
  static TextStyle buttonSmall(BuildContext context) {
    return getStyle(
      context, 
      lightStyle: buttonSmallLight, 
      darkStyle: buttonSmallDark
    );
  }
}