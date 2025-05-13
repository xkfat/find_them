import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const themeKey = 'theme_mode';
  
  ThemeCubit() : super(ThemeMode.light) {
    _loadThemePreference();
  }
  
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeMode = prefs.getString(themeKey);
      
      if (savedThemeMode != null) {
        emit(_getThemeModeFromString(savedThemeMode));
      }
    } catch (_) {
      emit(ThemeMode.light);
    }
  }
  
  Future<void> _saveThemePreference(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(themeKey, _getStringFromThemeMode(mode));
    } catch (_) {
    }
  }
  
  String _getStringFromThemeMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'light', 
    };
  }
  
  ThemeMode _getThemeModeFromString(String themeString) {
    return switch (themeString) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.light, 
    };
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == ThemeMode.system) {
      mode = ThemeMode.light;
    }
    
    if (state != mode) {
      emit(mode);
      await _saveThemePreference(mode);
    }
  }
  
  Future<void> setLightMode() async => await setThemeMode(ThemeMode.light);
  Future<void> setDarkMode() async => await setThemeMode(ThemeMode.dark);
  
  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      await setDarkMode();
    } else {
      await setLightMode();
    }
  }
  
  bool get isDarkMode => state == ThemeMode.dark;
}