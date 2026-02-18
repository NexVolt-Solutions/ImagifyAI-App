import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';

/// Reusable loading indicator widget with iOS (Cupertino) styling
class AppLoadingIndicator extends StatelessWidget {
  /// Size of the loading indicator (default: 20)
  final double? size;

  /// Color of the loading indicator (default: primary color)
  final Color? color;

  /// Radius of the CupertinoActivityIndicator (default: 10)
  final double? radius;

  /// Whether to use gradient color (default: false)
  final bool useGradient;

  const AppLoadingIndicator({
    super.key,
    this.size = 20,
    this.color,
    this.radius,
    this.useGradient = false,
  });

  /// Small loading indicator (17x17) - for inline use
  const AppLoadingIndicator.small({
    super.key,
    this.size = 17,
    this.color,
    this.radius,
    this.useGradient = false,
  });

  /// Medium loading indicator (24x24) - for buttons
  const AppLoadingIndicator.medium({
    super.key,
    this.size = 24,
    this.color,
    this.radius,
    this.useGradient = false,
  });

  /// Large loading indicator (40x40) - for full screen
  const AppLoadingIndicator.large({
    super.key,
    this.size = 40,
    this.color,
    this.radius,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    // Use theme-aware color: primary color from theme, which adapts to light/dark mode
    // If no color is provided, use primary color from theme (theme-aware)
    final indicatorColor = color ?? context.primaryColor;
    final indicatorSize = size ?? 20;
    final indicatorRadius =
        radius ?? (indicatorSize / 2) * 0.6; // Default radius based on size

    Widget indicator = SizedBox(
      width: indicatorSize,
      height: indicatorSize,
      child: CupertinoActivityIndicator(
        radius: indicatorRadius,
        color: indicatorColor,
      ),
    );

    // Apply gradient if requested (uses app gradient colors from theme)
    if (useGradient) {
      // Use theme-aware gradient: dark theme uses default gradient, light theme uses light gradient
      final gradient = context.isDarkMode
          ? AppColors.gradient
          : AppColors.gradientLight;

      return ShaderMask(
        shaderCallback: (bounds) {
          return gradient.createShader(bounds);
        },
        blendMode: BlendMode.srcIn,
        child: SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: CupertinoActivityIndicator(
            radius: indicatorRadius,
            color: Colors.white,
          ),
        ),
      );
    }

    return indicator;
  }
}
