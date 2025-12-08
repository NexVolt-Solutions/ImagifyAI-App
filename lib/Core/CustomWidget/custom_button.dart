import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final double? height;
  final double? width;
  final double? iconHeight;
  final double? iconWidth;
  final double? fontSize;
  final String? text;
  final VoidCallback? onPressed;
  final String? icon;

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
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: gradient,
          border: Border.all(color: borderColor ?? AppColors.blackColor),
          borderRadius: BorderRadius.circular(context.radius(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Image.asset(
                icon!,
                height: iconHeight ?? context.h(20),
                width: iconWidth ?? context.w(20),
                color: AppColors.whiteColor,
                fit: BoxFit.cover,
              ),
              SizedBox(width: context.w(5)),
            ],
            Text(
              text ?? "",
              style: GoogleFonts.poppins(
                color: AppColors.whiteColor,
                fontSize: fontSize ?? context.text(16),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
