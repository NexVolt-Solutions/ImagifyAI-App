import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeAlign extends StatelessWidget {
  final String? text;
  const HomeAlign({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text!,
          style: GoogleFonts.poppins(
            color: AppColors.whiteColor,
            fontSize: context.text(16),
            fontWeight: FontWeight.w500,
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_outlined,
          color: AppColors.whiteColor,
          size: context.h(15),
        ),
      ],
    );
  }
}
