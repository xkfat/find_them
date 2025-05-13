import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const themeKey = 'theme_mode';
  
  ThemeCubit() : super(const ThemeState(ThemeMode.system)) {
    _loadThemePreference();
  }
  
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeMode = prefs.getString(themeKey);
      
      if (savedThemeMode != null) {
        emit(ThemeState(_getThemeModeFromString(savedThemeMode)));
      }
    } catch (_) {
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
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }
  
  ThemeMode _getThemeModeFromString(String themeString) {
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    if (state.themeMode != mode) {
      emit(ThemeState(mode));
      await _saveThemePreference(mode);
    }
  }
  
  Future<void> setLightMode() async => await setThemeMode(ThemeMode.light);
  Future<void> setDarkMode() async => await setThemeMode(ThemeMode.dark);
  Future<void> setSystemMode() async => await setThemeMode(ThemeMode.system);
  
  Future<void> toggleTheme() async {
    if (state.themeMode == ThemeMode.light) {
      await setDarkMode();
    } else {
      await setLightMode();
    }
  }
}