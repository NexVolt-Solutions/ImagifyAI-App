import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/theme/theme_extensions.dart';

class CustomTextField extends StatelessWidget {
  final String validatorType;

  final String? hintText;
  final String? label;

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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label ?? "label",
            style: context.appTextStyles?.customTextFieldLabel,
          ),
        SizedBox(height: context.h(8)),
        TextFormField(
          controller: controller,
          keyboardType: keyboard ?? TextInputType.text,
          onChanged: onChanged,
          enabled: enabled ?? true,
          validator: (value) {
            // Password fields are optional - only validate if they have content
            if (validatorType == "password") {
              // If password field is empty, it's valid (optional field)
              if (value == null || value.trim().isEmpty) {
                return null;
              }
              // If password field has content, validate it (you can add password strength validation here if needed)
              // For now, just return null if it has content (validation happens in view model)
              return null;
            }
            
            // For all other fields, check if they're required
            if (value == null || value.trim().isEmpty) {
              return "This field is required";
            }
        
            if (validatorType == "name" && value.length < 3) {
              return "Enter a valid name";
            }
        
            if (validatorType == "phone" &&
                !RegExp(r'^[0-9]{10,13}$').hasMatch(value)) {
              return "Enter a valid phone number";
            }
        
            if (validatorType == "email") {
              // More comprehensive email validation regex
              // Allows: letters, numbers, dots, hyphens, underscores, plus signs before @
              // Allows: letters, numbers, dots, hyphens after @
              // Allows: TLD of 2-63 characters (supports longer TLDs like .museum, .technology)
              final emailRegex = RegExp(
                r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                caseSensitive: false,
              );
              if (!emailRegex.hasMatch(value.trim())) {
                return "Enter a valid email";
              }
            }
        
            return null;
          },
        
          style: context.appTextStyles?.customTextFieldInput,
        
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: context.padAll(10),
                    child: IconTheme(
                      data: IconThemeData(
                        color: iconColor ?? Theme.of(context).iconTheme.color,
                      ),
                      child: prefixIcon!,
                    ),
                  )
                : null,
        
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: context.padAll(10),
                    child: IconTheme(
                      data: IconThemeData(
                        color: iconColor ?? context.colorScheme.onSurface,
                      ),
                      child: suffixIcon!,
                    ),
                  )
                : null,
        
            hintText: hintText,
            hintStyle:
                hintStyle ??
                context.appTextStyles?.authHintText,
        
            filled: true,
            fillColor: fillColor ?? Colors.transparent,
        
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: enabledBorderColor ?? context.colorScheme.onSurface,
                width: borderWidth ?? context.w(1.5),
              ),
              borderRadius: BorderRadius.circular(
                borderRadius ?? context.radius(8),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: focusedBorderColor ?? context.colorScheme.primary,
                width: borderWidth ?? context.radius(1.5),
              ),
              borderRadius: BorderRadius.circular(
                context.radius(8),
              ),
            ),
                border: OutlineInputBorder(
              borderSide: BorderSide(
                color: context.colorScheme.primary,
                  width: borderWidth ?? context.w(1.5),
              ),
              borderRadius: BorderRadius.circular(
                borderRadius ?? context.radius(8),
              ) 
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: context.colorScheme.error,
                width: borderWidth ?? context.w(1.5),
              ),
              borderRadius: BorderRadius.circular(context.radius(8)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: context.colorScheme.error,
                width: borderWidth ?? context.w(1.5),
              ),
              borderRadius: BorderRadius.circular(context.radius(8)),
            ),
          ),
        ),
      ],
    );
  }
}
