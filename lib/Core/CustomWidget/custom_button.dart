import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final double height;
  final double width;
  final String text;
  final VoidCallback? onPressed;
  final String? icon;
  const CustomButton({
    super.key,
    required this.height,
    required this.width,
    required this.text,
    this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9F56FE), Color(0xFFD5B4FF)],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
