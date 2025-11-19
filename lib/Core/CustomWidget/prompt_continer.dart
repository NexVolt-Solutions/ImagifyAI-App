import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class PromptContiner extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const PromptContiner({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 4.h),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 23.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? AppColors.appMainColor : Colors.white,
                width: 1.5,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
