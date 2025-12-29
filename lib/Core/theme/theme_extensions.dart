import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/theme/app_theme.dart';

/// Extension to easily access theme-aware colors from BuildContext
extension ThemeExtension on BuildContext {
  /// Get the current theme
  ThemeData get theme => Theme.of(this);
  
  /// Get the current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Check if dark mode is active
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  /// Check if light mode is active
  bool get isLightMode => Theme.of(this).brightness == Brightness.light;
  
  /// Get primary color from theme
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  
  /// Get background color from theme
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
  
  /// Get surface color from theme
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  
  /// Get text color based on theme
  Color get textColor => Theme.of(this).textTheme.bodyLarge?.color ?? 
                        (isDarkMode ? Colors.white : Colors.black);
  
  /// Get subtitle text color based on theme
  Color get subtitleColor => Theme.of(this).textTheme.bodySmall?.color ?? 
                             (isDarkMode ? AppColors.subTitleColor : Colors.black54);
  
  /// Get AppTextStyles extension from theme
  AppTextStyles? get appTextStyles => Theme.of(this).extension<AppTextStyles>();
}

/// Helper class for theme-aware colors
class ThemeColors {
  ThemeColors._();
  
  /// Get background color based on theme brightness
  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }
  
  /// Get surface color based on theme brightness
  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }
  
  /// Get text color based on theme brightness
  static Color textColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
  
  /// Get subtitle color based on theme brightness
  static Color subtitleColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? AppColors.subTitleColor 
        : Colors.black54;
  }
  
  /// Get container color based on theme brightness
  static Color containerColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? AppColors.containerColor 
        : Colors.grey[50]!;
  }
  
  /// Get border color based on theme brightness
  static Color borderColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? AppColors.textFieldBoderColor 
        : AppColors.textFieldBoderColor;
  }
  
  /// Get AppTextStyles extension from theme
  static AppTextStyles? textStyles(BuildContext context) {
    return Theme.of(context).extension<AppTextStyles>();
  }
}

