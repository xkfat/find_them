// lib/data/services/profile_preferences_service.dart

import 'dart:convert';
import 'dart:developer';
import 'package:find_them/data/services/api_service.dart';
import 'package:find_them/data/models/enum.dart';
import 'package:find_them/data/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilePreferencesService {
  final ApiService _apiService = ApiService();
  static const String baseUrl = 'http://10.0.2.2:8000/api/accounts';

  Future<User?> getUserProfile() async {
    try {
      final token = await _apiService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return User.fromJson(userData);
      } else {
        log('Failed to load profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error getting profile: $e');
      return null;
    }
  }

  Future<bool> updateLanguagePreference(Language language) async {
    try {
      final token = await _apiService.getAccessToken();
      
      final response = await http.patch(
        Uri.parse('$baseUrl/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'language': language.value, // 'english', 'french', 'arabic'
        }),
      );

      if (response.statusCode == 200) {
        // Cache locally for offline use
        await _cacheLanguage(language);
        log('✅ Language updated to: ${language.value}');
        return true;
      } else {
        log('❌ Failed to update language: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('❌ Error updating language: $e');
      return false;
    }
  }

  Future<bool> updateThemePreference(Theme theme) async {
    try {
      final token = await _apiService.getAccessToken();
      
      final response = await http.patch(
        Uri.parse('$baseUrl/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'theme': theme.value, // 'light' or 'dark'
        }),
      );

      if (response.statusCode == 200) {
        // Cache locally for offline use
        await _cacheTheme(theme);
        log('✅ Theme updated to: ${theme.value}');
        return true;
      } else {
        log('❌ Failed to update theme: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('❌ Error updating theme: $e');
      return false;
    }
  }

  Future<bool> updateBothPreferences(Language language, Theme theme) async {
    try {
      final token = await _apiService.getAccessToken();
      
      final response = await http.patch(
        Uri.parse('$baseUrl/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'language': language.value,
          'theme': theme.value,
        }),
      );

      if (response.statusCode == 200) {
        // Cache both locally
        await _cacheLanguage(language);
        await _cacheTheme(theme);
        log('✅ Both preferences updated: ${language.value}/${theme.value}');
        return true;
      } else {
        log('❌ Failed to update preferences: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('❌ Error updating preferences: $e');
      return false;
    }
  }

  // Get preferences from local cache (fallback)
  Future<Map<String, dynamic>> getCachedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'language': prefs.getString('cached_language') ?? 'english',
      'theme': prefs.getString('cached_theme') ?? 'light',
    };
  }

  // Load preferences from server or cache
  Future<Map<String, dynamic>> loadPreferences() async {
    try {
      final user = await getUserProfile();
      if (user != null) {
        // Cache the server preferences locally
        await _cacheLanguage(user.language);
        await _cacheTheme(user.theme);
        
        return {
          'language': user.language.value,
          'theme': user.theme.value,
        };
      } else {
        // Fallback to cached preferences
        return await getCachedPreferences();
      }
    } catch (e) {
      log('Error loading preferences: $e');
      return await getCachedPreferences();
    }
  }

  // Private helper methods for caching
  Future<void> _cacheLanguage(Language language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_language', language.value);
  }

  Future<void> _cacheTheme(Theme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_theme', theme.value);
  }

  // Clear cached preferences (call this on logout)
  Future<void> clearCachedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_language');
      await prefs.remove('cached_theme');
      log('✅ Cached preferences cleared');
    } catch (e) {
      log('❌ Error clearing cached preferences: $e');
    }
  }

  // Check if user is logged in (has token)
  Future<bool> isUserLoggedIn() async {
    return await _apiService.hasToken();
  }

  // Sync local preferences to server (when user logs in)
  Future<bool> syncLocalPreferencesToServer() async {
    try {
      if (!await isUserLoggedIn()) return false;

      final cached = await getCachedPreferences();
      final language = LanguageExtension.fromValue(cached['language']);
      final theme = ThemeExtension.fromValue(cached['theme']);

      return await updateBothPreferences(language, theme);
    } catch (e) {
      log('Error syncing preferences to server: $e');
      return false;
    }
  }
}