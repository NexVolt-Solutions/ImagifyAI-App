# Theme System Setup Guide

## Overview
A comprehensive theme system has been added to the app using Provider. The system supports:
- ✅ Light and Dark themes
- ✅ Theme persistence (saved to SharedPreferences)
- ✅ Easy theme switching
- ✅ Theme-aware color helpers
- ✅ Custom theme toggle widgets

## Files Created

### 1. `lib/viewModel/theme_provider.dart`
- Manages theme state using ChangeNotifier
- Persists theme preference to SharedPreferences
- Provides methods to toggle and set theme mode
- Default theme: Dark mode

### 2. `lib/Core/theme/app_theme.dart`
- Defines light and dark theme configurations
- Includes all Material 3 theme customizations
- Matches your existing AppColors design

### 3. `lib/Core/theme/theme_extensions.dart`
- Extension methods for easy theme access
- Helper class for theme-aware colors
- Simplifies accessing theme colors in widgets

### 4. `lib/Core/CustomWidget/theme_toggle_button.dart`
- Ready-to-use theme toggle widgets
- `ThemeToggleButton` - Icon button for theme switching
- `ThemeToggleSwitch` - Switch with label for settings

## Integration

### Already Integrated
✅ ThemeProvider added to MultiProvider in `my_app.dart`
✅ MaterialApp wrapped with Consumer to use theme
✅ Light and dark themes configured
✅ Theme persistence enabled

## Usage Examples

### 1. Access Theme in Widgets

```dart
// Using extension
final isDark = context.isDarkMode;
final primaryColor = context.primaryColor;
final backgroundColor = context.backgroundColor;

// Using ThemeColors helper
final textColor = ThemeColors.textColor(context);
final containerColor = ThemeColors.containerColor(context);
```

### 2. Toggle Theme Programmatically

```dart
// Get ThemeProvider
final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

// Toggle theme
themeProvider.toggleTheme();

// Set specific theme
themeProvider.setThemeMode(ThemeMode.light);
themeProvider.setThemeMode(ThemeMode.dark);
themeProvider.setThemeMode(ThemeMode.system);
```

### 3. Use Theme Toggle Widgets

```dart
// Simple icon button
ThemeToggleButton()

// Switch with label (for settings screen)
ThemeToggleSwitch()
```

### 4. Listen to Theme Changes

```dart
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    final isDark = themeProvider.isDarkMode;
    return Container(
      color: isDark ? Colors.black : Colors.white,
      child: Text('Theme: ${isDark ? "Dark" : "Light"}'),
    );
  },
)
```

## Theme Modes

- **ThemeMode.dark** - Always dark theme
- **ThemeMode.light** - Always light theme  
- **ThemeMode.system** - Follows system theme (can be added)

## Current Theme Colors

### Dark Theme (Default)
- Background: `AppColors.blackColor`
- Surface: `AppColors.containerColor`
- Primary: `AppColors.primeryColor` (Purple)
- Text: White

### Light Theme
- Background: White
- Surface: Light grey
- Primary: `AppColors.primeryColor` (Purple)
- Text: Black

## Adding Theme Toggle to Settings/Profile

To add a theme toggle button to your profile or settings screen:

```dart
import 'package:genwalls/Core/CustomWidget/theme_toggle_button.dart';

// In your settings screen
ThemeToggleSwitch()
```

Or use the icon button version:

```dart
ThemeToggleButton()
```

## Migration Guide

### Replacing Hardcoded Colors

**Before:**
```dart
Container(
  color: AppColors.blackColor,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.whiteColor),
  ),
)
```

**After (Theme-aware):**
```dart
Container(
  color: Theme.of(context).scaffoldBackgroundColor,
  child: Text(
    'Hello',
    style: TextStyle(
      color: Theme.of(context).textTheme.bodyLarge?.color,
    ),
  ),
)
```

Or using extensions:
```dart
Container(
  color: context.backgroundColor,
  child: Text(
    'Hello',
    style: TextStyle(color: context.textColor),
  ),
)
```

## Notes

- Default theme is **Dark mode** (matches your current design)
- Theme preference is automatically saved and restored
- All existing AppColors are still available for backward compatibility
- Gradually migrate widgets to use theme-aware colors for better theme support

## Testing

1. Run the app - it should start in dark mode
2. Add ThemeToggleButton to any screen
3. Toggle theme and verify colors change
4. Restart app - theme preference should persist

