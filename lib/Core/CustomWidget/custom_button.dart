import 'package:flutter/material.dart';
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
    final double? buttonWidth = width ?? double.infinity;

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

        Widget buttonContent = Container(
          height: height ?? context.h(48),
          width: actualWidth,
          padding: EdgeInsets.symmetric(horizontal: context.w(16)),
          decoration: BoxDecoration(
            gradient: gradient,

            border: Border.all(color: borderColor ?? context.backgroundColor),
            borderRadius: BorderRadius.circular(context.radius(8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (isLoading) ...[
                const AppLoadingIndicator.medium(color: Colors.white),
                SizedBox(width: context.w(8)),
              ] else if (icon != null) ...[
                Image.asset(
                  icon!,
                  height: iconHeight ?? context.h(20),
                  width: iconWidth ?? context.w(20),
                  color: Colors.white,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: context.w(5)),
              ],
              Flexible(
                child: Text(
                  text ?? "",
                  style:
                      (context.appTextStyles?.customButtonText ?? TextStyle())
                          .copyWith(fontSize: fontSize ?? context.text(16)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
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
}
