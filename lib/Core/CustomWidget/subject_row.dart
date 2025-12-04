import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:google_fonts/google_fonts.dart';

class SubjectRow extends StatelessWidget {
  final text1;
  final text2;
  final text3;
  final text4;
  const SubjectRow({super.key, this.text1, this.text2, this.text3, this.text4});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 10.r,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.check, color: Colors.black, size: 12.sp),
                ),
                SizedBox(width: 10.w),
                Text(
                  text1,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 10.r,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.check, color: Colors.black, size: 12.sp),
                ),
                SizedBox(width: 10.w),
                Text(
                  text2,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 10.r,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.check, color: Colors.black, size: 12.sp),
                ),
                SizedBox(width: 10.w),
                Text(
                  text3,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 10.r,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.check, color: Colors.black, size: 12.sp),
                ),
                SizedBox(width: 10.w),
                Text(
                  text4,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
