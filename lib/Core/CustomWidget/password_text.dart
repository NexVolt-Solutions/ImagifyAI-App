import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordText extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;

  const PasswordText({
    super.key,
    required this.text,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 3.h),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18.sp),
          SizedBox(width: 10.w),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
