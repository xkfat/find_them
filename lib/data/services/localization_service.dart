import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en';

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('fr', ''), 
    Locale('ar', ''), 
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'fr': 'Français',
    'ar': 'العربية',
  };

  static Future<String> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? _defaultLanguage;
  }

  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  static Locale getLocaleFromLanguage(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return const Locale('fr', '');
      case 'ar':
        return const Locale('ar', '');
      default:
        return const Locale('en', '');
    }
  }

  static String getLanguageFromLocale(Locale locale) {
    return locale.languageCode;
  }

  static bool isLocaleSupported(Locale locale) {
    return supportedLocales.any((supportedLocale) =>
        supportedLocale.languageCode == locale.languageCode);
  }
}