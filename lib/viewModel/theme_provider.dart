import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark theme
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  ThemeProvider() {
    _loadThemeMode();
  }

  /// Load saved theme preference from SharedPreferences
  /// If no preference is saved, defaults to dark theme
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      
      if (savedTheme != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedTheme,
          orElse: () => ThemeMode.dark, // Fallback to dark if saved value is invalid
        );
        if (kDebugMode) {
          print('✅ Theme loaded from storage: $_themeMode');
        }
        notifyListeners();
      } else {
        // No saved preference - ensure default is dark
        _themeMode = ThemeMode.dark;
        if (kDebugMode) {
          print('✅ No saved theme preference, using default: $_themeMode');
        }
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading theme: $e');
      }
      // On error, ensure default is dark
      _themeMode = ThemeMode.dark;
      notifyListeners();
    }
  }

  /// Save theme preference to SharedPreferences
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, _themeMode.toString());
      if (kDebugMode) {
        print('✅ Theme saved to storage: $_themeMode');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving theme: $e');
      }
    }
  }

  /// Set theme mode and save preference
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _saveThemeMode();
      notifyListeners();
      if (kDebugMode) {
        print('🔄 Theme changed to: $mode');
      }
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
}

