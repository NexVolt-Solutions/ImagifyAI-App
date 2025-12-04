import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:google_fonts/google_fonts.dart';

class NormalText extends StatelessWidget {
  final String? titleText;
  final String? subText;

  final double? titleSize;
  final double? subSize;

  final FontWeight? titleWeight;
  final FontWeight? subWeight;

  final Color? titleColor;
  final Color? subColor;

  final TextAlign? titleAlign;
  final TextAlign? subAlign;
  final CrossAxisAlignment? crossAxisAlignment;

  const NormalText({
    super.key,
    this.titleText,
    this.subText,
    this.titleSize,
    this.subSize,
    this.titleWeight,
    this.subWeight,
    this.titleColor,
    this.subColor,
    this.titleAlign,
    this.subAlign,
    this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      children: [
        if (titleText != null)
          Text(
            titleText!,
            style: GoogleFonts.poppins(
              color: titleColor ?? AppColors.whiteColor,
              fontSize: titleSize ?? context.text(16),
              fontWeight: titleWeight ?? FontWeight.w500,
            ),
            textAlign: titleAlign ?? TextAlign.start,
          ),

        if (subText != null)
          Text(
            subText!,
            style: GoogleFonts.poppins(
              color: subColor ?? AppColors.whiteColor,
              fontSize: subSize ?? context.text(14),
              fontWeight: subWeight ?? FontWeight.w400,
            ),
            textAlign: subAlign ?? TextAlign.start,
          ),
      ],
    );
  }
}
