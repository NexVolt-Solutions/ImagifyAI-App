import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateAlignText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;

  const UpdateAlignText({
    super.key,
    required this.text,
    required this.color,
    required this.fontSize,
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
            fontSize: fontSize.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
