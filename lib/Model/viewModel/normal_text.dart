import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NormalText extends StatelessWidget {
  final text;
  final fontSize;
  final color;
  final fontWeight;
  const NormalText({
    super.key,
    this.text,
    this.fontSize,
    this.color,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}
