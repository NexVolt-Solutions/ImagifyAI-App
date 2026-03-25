import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';

class CustomButton extends StatelessWidget {
  final double? height;
  final double? width;
  final double? iconHeight;
  final double? iconWidth;
  final double? fontSize;
  final String? text;
  final VoidCallback? onPressed;
  final String? icon;
  final bool isLoading;

  final Color? borderColor;
  final Gradient? gradient;

  const CustomButton({
    super.key,
    this.height,
    this.width,
    this.text,
    this.onPressed,
    this.icon,
    this.borderColor,
    this.gradient,
    this.iconHeight,
    this.iconWidth,
    this.fontSize,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = width ?? double.infinity;
    final isFilled = gradient != null;
    // Filled (gradient): white text/icon. Outline (no gradient): theme onSurface so light theme = dark text, dark theme = white.
    final contentColor = isFilled
        ? (context.appTextStyles?.customButtonText.color ??
              context.colorScheme.onPrimary)
        : context.colorScheme.onSurface;
    // Outline button border: in light theme use primary or onSurface for visibility; dark theme unchanged.
    final effectiveBorderColor =
        borderColor ??
        (isFilled ? context.backgroundColor : context.colorScheme.onSurface);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the actual width to use based on constraints
        double? actualWidth = buttonWidth;

        // If width is infinity and constraints are unbounded (e.g., inside Row),
        // don't set width (let it size to content)
        if (buttonWidth == double.infinity &&
            constraints.maxWidth == double.infinity) {
          actualWidth = null;
        }

        final maxW = constraints.maxWidth;
        final tightWidth = maxW.isFinite && maxW < 160;
        final horizontalPadding = tightWidth ? 8.0 : context.w(24);
        final labelBounded = maxW.isFinite;

        Widget buttonContent = Container(
          height: height ?? context.h(48),
          width: actualWidth,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            gradient: gradient,

            border: Border.all(color: effectiveBorderColor),
            borderRadius: BorderRadius.circular(context.radius(8)),
          ),
          child: isLoading
              ? Center(child: AppLoadingIndicator.medium(color: contentColor))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: labelBounded
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      _buildIcon(
                        context,
                        icon!,
                        iconHeight ?? context.h(24),
                        iconWidth ?? context.w(24),
                        contentColor,
                      ),
                    ],
                    if (text != null && (text!.isNotEmpty)) ...[
                      SizedBox(width: icon != null ? context.w(5) : 0),
                      if (labelBounded)
                        Flexible(
                          child: Text(
                            text!,
                            style:
                                (context.appTextStyles?.customButtonText ??
                                        TextStyle(color: contentColor))
                                    .copyWith(
                                      fontSize: fontSize ?? context.text(14),
                                      color: contentColor,
                                    ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        Text(
                          text!,
                          style:
                              (context.appTextStyles?.customButtonText ??
                                      TextStyle(color: contentColor))
                                  .copyWith(
                                    fontSize: fontSize ?? context.text(14),
                                    color: contentColor,
                                  ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ],
                ),
        );

        // If width is infinity and we have bounded constraints, wrap in SizedBox
        if (buttonWidth == double.infinity &&
            constraints.maxWidth != double.infinity) {
          return GestureDetector(
            onTap: isLoading ? null : onPressed,
            child: Opacity(
              opacity: isLoading ? 0.7 : 1.0,
              child: SizedBox(width: double.infinity, child: buttonContent),
            ),
          );
        }

        return GestureDetector(
          onTap: isLoading ? null : onPressed,
          child: Opacity(opacity: isLoading ? 0.7 : 1.0, child: buttonContent),
        );
      },
    );
  }

  static Widget _buildIcon(
    BuildContext context,
    String path,
    double height,
    double width,
    Color color,
  ) {
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        height: height,
        width: width,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        fit: BoxFit.contain,
      );
    }
    return Image.asset(
      path,
      height: height,
      width: width,
      color: color,
      fit: BoxFit.contain,
    );
  }
}
