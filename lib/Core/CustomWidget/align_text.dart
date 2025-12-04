import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:google_fonts/google_fonts.dart';

class AlignText extends StatelessWidget {
  final String? text;
  final FontWeight? fontWeight;
  final double? fontSize;
  const AlignText({
    super.key,
    required this.text,
    this.fontWeight,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.h(20)),
        child: Text(
          text!,
          style: GoogleFonts.poppins(
            color: AppColors.whiteColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}
