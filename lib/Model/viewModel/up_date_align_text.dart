import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateAlignText extends StatelessWidget {
  final text;
  final color;
  final fontSize;

  const UpdateAlignText({super.key, this.text, this.color, this.fontSize});

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
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
