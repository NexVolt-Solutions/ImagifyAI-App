import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/viewModel/theme_provider.dart';
import 'package:provider/provider.dart';

/// A widget to toggle between light and dark themes
class ThemeToggleButton extends StatelessWidget {
  final bool showLabel;
  final IconData? lightIcon;
  final IconData? darkIcon;

  const ThemeToggleButton({
    super.key,
    this.showLabel = true,
    this.lightIcon,
    this.darkIcon,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return IconButton(
      icon: Icon(
        isDark
            ? (darkIcon ?? Icons.light_mode)
            : (lightIcon ?? Icons.dark_mode),
        color: AppColors.primeryColor,
      ),
      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      onPressed: () {
        themeProvider.toggleTheme();
      },
    );
  }
}

/// A switch widget to toggle theme with label
class ThemeToggleSwitch extends StatelessWidget {
  const ThemeToggleSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return SwitchListTile(
      title: const Text('Dark Mode'),
      subtitle: Text(isDark ? 'Dark theme enabled' : 'Light theme enabled'),
      value: isDark,
      onChanged: (value) {
        themeProvider.toggleTheme();
      },
      secondary: Icon(
        isDark ? Icons.dark_mode : Icons.light_mode,
        color: AppColors.primeryColor,
      ),
    );
  }
}
