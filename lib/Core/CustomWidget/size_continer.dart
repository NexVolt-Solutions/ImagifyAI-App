import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:genwalls/Core/Constants/app_colors.dart'; // path sahi laga lena

class SizeContiner extends StatelessWidget {
  final double height1;
  final double width1;
  final double height2;
  final double width2;
   final String text2;
  final bool isSelected;
  final VoidCallback? onTap;

  const SizeContiner({
    super.key,
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
        width: width1 == double.infinity ? null : width1, // Allow flexible width
        constraints: width1 == double.infinity 
            ? BoxConstraints(minWidth: 0, maxWidth: double.infinity)
            : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.radius(8)),
          border: Border.all(
            color: isSelected ? AppColors.primeryColor : AppColors.whiteColor,
            width: context.w(1.5),
          ),
        ),
        child: Padding(
          padding: context.padSym(h: 8), // Reduced horizontal padding
          child: Center(
            child: Text(
              text2,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: context.text(11), // Slightly smaller font
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
