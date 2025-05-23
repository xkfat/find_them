import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:find_them/data/models/enum.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial()) {
    _loadTheme();
  }

  static const String _themeKey = 'app_theme';

  void toggleTheme() {
    if (state is ThemeChanged) {
      final currentState = state as ThemeChanged;
      final newTheme = currentState.currentTheme == Theme.light 
          ? Theme.dark 
          : Theme.light;
      emit(ThemeChanged(newTheme));
      _saveTheme(newTheme);
    } else {
      emit(const ThemeChanged(Theme.dark));
      _saveTheme(Theme.dark);
    }
  }

  void setTheme(Theme theme) {
    emit(ThemeChanged(theme));
    _saveTheme(theme);
  }

  Theme getCurrentTheme() {
    if (state is ThemeChanged) {
      return (state as ThemeChanged).currentTheme;
    }
    return Theme.light;
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeValue = prefs.getString(_themeKey) ?? 'light';
      final theme = ThemeExtension.fromValue(themeValue);
      emit(ThemeChanged(theme));
    } catch (e) {
      emit(const ThemeChanged(Theme.light));
    }
  }

  Future<void> _saveTheme(Theme theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, theme.value);
    } catch (e) {
      
    }
  }
}