import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
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
      padding: EdgeInsets.symmetric(vertical: context.h(4)),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: context.text(18)),
          SizedBox(width: context.w(8)),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: AppColors.whiteColor,
              fontSize: context.text(10),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
