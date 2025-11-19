import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeAlign extends StatelessWidget {
  final String? text;
  const HomeAlign({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text!,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_outlined,
            color: Colors.white,
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}
