import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeColors {
  // Dark Mode Colors
  static const Color darkBackgroundGradientTop = Color(0xFF0D1B2A);
  static const Color darkBackgroundGradientBottom = Color(0xFF1B263B);
  static const Color darkFilterGradientTop = Color(0xFF1B1B2F);
  static const Color darkFilterGradientBottom = Color(0xFF16213E);
  static const List<Color> darkFilterEntries = [
    Color(0xFF415A77),
    Color(0xFF778DA9),
    Color(0xFF1E6091),
    Color(0xFF76C7C0),
  ];
  static const Color darkButtonColor = Color(0xFFEF8354);
  static const Color darkBackgroundStarfishImage = Color(0xFFFFFFFF);

  // Light Mode Colors
  static const Color lightBackgroundGradientTop = Color(0xFFBEE3DB);
  static const Color lightBackgroundGradientBottom = Color(0xFFE3FDFD);
  static const Color lightFilterGradientTop = Color(0xFFFFF1E6);
  static const Color lightFilterGradientBottom = Color(0xFFFFEDD8);
  static const List<Color> lightFilterEntries = [
    Color(0xFF76C7C0),
    Color(0xFFADE8F4),
    Color(0xFFCAF0F8),
    Color(0xFFFFD6A5),
  ];
  static const Color lightButtonColor = Color(0xFF0077B6);
  static const Color lightBackgroundStarfishImage = Color(0xFF003C4D);
}

class ThemePreference {
  static const String _keyIsDarkMode = "isDarkMode";

  // Save the theme mode
  static Future<void> saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDarkMode, isDarkMode);
  }

  // Load the theme mode
  static Future<bool> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsDarkMode) ?? false; // Default to light mode
  }
}
