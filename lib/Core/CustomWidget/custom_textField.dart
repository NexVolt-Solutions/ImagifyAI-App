import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String validatorType;

  final String? hintText;
  final String? label;

  final TextEditingController? controller;
  final TextInputType? keyboard;

  final Color? fillColor;
  final Color? hintColor;
  final TextStyle? hintStyle;

  final double? borderRadius;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final double? borderWidth;
  final Widget? prefixIcon;

  final Widget? suffixIcon;
  final Color? iconColor;

  const CustomTextField({
    super.key,
    required this.validatorType,
    this.hintText,
    this.controller,
    this.keyboard,
    this.fillColor,
    this.hintColor,
    this.hintStyle,
    this.borderRadius,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.label,
    this.borderWidth,
    this.prefixIcon,
    this.suffixIcon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label ?? "label",
            style: GoogleFonts.poppins(
              color: AppColors.whiteColor,
              fontSize: context.text(14),
              fontWeight: FontWeight.w500,
            ),
          ),
        SizedBox(height: context.h(8)),
        SizedBox(
          height: context.h(48),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboard ?? TextInputType.text,

            validator: (value) {
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

              if (validatorType == "email" &&
                  !RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$").hasMatch(value)) {
                return "Enter a valid email";
              }

              return null;
            },

            style: GoogleFonts.poppins(
              color: AppColors.whiteColor,
              fontSize: context.text(14),
              fontWeight: FontWeight.w500,
            ),

            decoration: InputDecoration(
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: context.padAll(10),
                      child: IconTheme(
                        data: IconThemeData(
                          color: iconColor ?? AppColors.whiteColor,
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
                          color: iconColor ?? AppColors.textFieldIconColor,
                        ),
                        child: suffixIcon!,
                      ),
                    )
                  : null,

              hintText: hintText,
              hintStyle:
                  hintStyle ??
                  TextStyle(
                    color: hintColor ?? AppColors.whiteColor,
                    fontSize: context.text(14),
                  ),

              filled: true,
              fillColor: fillColor ?? AppColors.blackColor,

              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: enabledBorderColor ?? AppColors.whiteColor,
                  width: borderWidth ?? context.w(1.5),
                ),
                borderRadius: BorderRadius.circular(
                  borderRadius ?? context.radius(8),
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: focusedBorderColor ?? AppColors.whiteColor,
                  width: borderWidth ?? context.radius(1.5),
                ),
                borderRadius: BorderRadius.circular(
                  borderRadius ?? context.radius(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
