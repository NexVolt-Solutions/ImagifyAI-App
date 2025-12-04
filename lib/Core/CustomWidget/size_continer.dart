import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:genwalls/Core/Constants/app_colors.dart'; // path sahi laga lena

class SizeContiner extends StatelessWidget {
  final double height1;
  final double width1;
  final double height2;
  final double width2;
  final String text1;
  final String text2;
  final bool isSelected;
  final VoidCallback? onTap;

  const SizeContiner({
    super.key,
    required this.text1,
    required this.text2,
    required this.height1,
    required this.width1,
    required this.height2,
    required this.width2,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height1,
        width: width1,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.radius(8)),
          border: Border.all(
            color: isSelected ? AppColors.primeryColor : AppColors.whiteColor,
            width: context.w(1.5),
          ),
        ),
        child: Padding(
          padding: context.padSym(h: 12),
          child: Center(
            child: Row(
              children: [
                Container(
                  height: height2,
                  width: width2,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primeryColor
                          : AppColors.whiteColor,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      text1,
                      style: GoogleFonts.poppins(
                        color: AppColors.whiteColor,
                        fontSize: context.text(10),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.w(8)),
                Text(
                  text2,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: context.text(12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
