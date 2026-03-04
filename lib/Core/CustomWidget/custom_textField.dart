import 'package:flutter/material.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';

/// Standard sizing and border widths for the text field.
class _TextFieldSizes {
  _TextFieldSizes._();

  static const double borderRadius = 12;
  static const double borderWidthDefault = 1.0;
  static const double borderWidthFocused = 2.0;
  static const double labelSpacing = 6;
  static const double contentPaddingH = 16;
  static const double contentPaddingV = 14;
  static const double iconPadding = 12;
}

class CustomTextField extends StatelessWidget {
  final String validatorType;

  final String? hintText;
  final String? label;
  /// When set, shown when the field is empty (instead of generic "This field is required").
  /// Use e.g. "Email is required" or "Password is required" for sign-in.
  final String? emptyErrorMessage;

  final TextEditingController? controller;
  final TextInputType? keyboard;

  final Color? fillColor;
  final Color? hintColor;
  final TextStyle? hintStyle;
  final bool? enabled;
  final double? borderRadius;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final double? borderWidth;
  final Widget? prefixIcon;

  final Widget? suffixIcon;
  final Color? iconColor;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.validatorType,
    this.hintText,
    this.controller,
    this.keyboard,
    this.fillColor,
    this.hintColor,
    this.hintStyle,
    this.enabled,
    this.borderRadius,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.label,
    this.borderWidth,
    this.prefixIcon,
    this.suffixIcon,
    this.iconColor,
    this.onChanged,
    this.emptyErrorMessage,
  });

  double get _radius => borderRadius ?? _TextFieldSizes.borderRadius;
  double get _borderWidth => borderWidth ?? _TextFieldSizes.borderWidthDefault;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = enabled ?? true;

    final enabledColor =
        enabledBorderColor ?? colorScheme.onSurface.withOpacity(0.42);
    final focusedColor = focusedBorderColor ?? colorScheme.primary;
    final errorColor = colorScheme.error;
    final disabledColor = colorScheme.onSurface.withOpacity(0.24);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: context.appTextStyles?.customTextFieldLabel,
          ),
          const SizedBox(height: _TextFieldSizes.labelSpacing),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboard ?? TextInputType.text,
          onChanged: onChanged,
          enabled: isEnabled,
          validator: _validate,
          style: context.appTextStyles?.customTextFieldInput,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: EdgeInsets.all(_TextFieldSizes.iconPadding),
                    child: IconTheme(
                      data: IconThemeData(
                        size: 24,
                        color: iconColor ?? colorScheme.onSurface,
                      ),
                      child: prefixIcon!,
                    ),
                  )
                : null,
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: EdgeInsets.all(_TextFieldSizes.iconPadding),
                    child: IconTheme(
                      data: IconThemeData(
                        size: 24,
                        color: iconColor ?? colorScheme.onSurface,
                      ),
                      child: suffixIcon!,
                    ),
                  )
                : null,
            hintText: hintText,
            hintStyle: hintStyle ?? context.appTextStyles?.authHintText,
            filled: true,
            fillColor: fillColor ?? Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _TextFieldSizes.contentPaddingH,
              vertical: _TextFieldSizes.contentPaddingV,
            ),
            // Enabled: neutral border
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radius),
              borderSide: BorderSide(
                color: enabledColor,
                width: _borderWidth,
              ),
            ),
            // Focused: primary, thicker
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radius),
              borderSide: BorderSide(
                color: focusedColor,
                width: _TextFieldSizes.borderWidthFocused,
              ),
            ),
            // Default / base
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radius),
              borderSide: BorderSide(
                color: enabledColor,
                width: _borderWidth,
              ),
            ),
            // Disabled: muted
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radius),
              borderSide: BorderSide(
                color: disabledColor,
                width: _borderWidth,
              ),
            ),
            // Error: error color, default width
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radius),
              borderSide: BorderSide(
                color: errorColor,
                width: _borderWidth,
              ),
            ),
            // Focused + error: error color, thicker
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radius),
              borderSide: BorderSide(
                color: errorColor,
                width: _TextFieldSizes.borderWidthFocused,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String? _validate(String? value) {
    final isEmpty = value == null || value.trim().isEmpty;
    if (isEmpty) {
      if (emptyErrorMessage != null) return emptyErrorMessage;
      if (validatorType == "password") return null;
      return "This field is required";
    }

    if (validatorType == "password") return null;

    if (validatorType == "name" && value.length < 3) {
      return "Enter a valid name";
    }

    if (validatorType == "phone" &&
        !RegExp(r'^[0-9]{10,13}$').hasMatch(value)) {
      return "Enter a valid phone number";
    }

    if (validatorType == "email") {
      final emailRegex = RegExp(
        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
        caseSensitive: false,
      );
      if (!emailRegex.hasMatch(value.trim())) {
        return "Enter a valid email";
      }
    }

    return null;
  }
}
