import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AlignText extends StatelessWidget {
  final String? text;
  final FontWeight? fontWeight;
  final double? fontSize;
  final color;
  const AlignText({
    super.key,
    required this.text,
    this.fontWeight,
    this.fontSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0.w),
        child: Text(
          text!,
          style: GoogleFonts.poppins(
            color: Colors.white ?? color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}
