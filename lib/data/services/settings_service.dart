import 'package:shared_preferences/shared_preferences.dart';
import 'package:find_them/data/models/enum.dart';

class SettingsService {
  static const String _themeKey = 'app_theme';
  static const String _languageKey = 'app_language';
  
  Future<void> saveTheme(Theme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.value);
  }
  
  Future<Theme> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(_themeKey);
    return themeStr != null ? ThemeExtension.fromValue(themeStr) : Theme.light;
  }
  
  Future<void> saveLanguage(Language language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.code);
  }
  
  Future<Language> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_languageKey);
    
    if (langCode == 'fr') return Language.french;
    if (langCode == 'ar') return Language.arabic;
    return Language.english;
  }
}