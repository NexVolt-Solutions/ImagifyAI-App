import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class IconCustomButton extends StatelessWidget {
  final onPressed;
  final text;
  final icon;
  final height;
  final width;
  const IconCustomButton({
    super.key,
    this.onPressed,
    this.text,
    this.icon,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9F56FE), Color(0xFFD5B4FF)],
            begin: Alignment.topLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              height: 20.h,
              width: 20.w,
              color: Colors.white,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 5.w),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
