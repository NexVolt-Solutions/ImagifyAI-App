import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Model/utils/Routes/routes_name.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextRich extends StatelessWidget {
  const CustomTextRich({
    super.key,
    this.text1,
    this.text2,
    this.textSize1,
    this.textSize2,
  });
  final String? text1;
  final String? text2;
  final double? textSize1;
  final double? textSize2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Align(
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: text1,
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: text2,
                style: GoogleFonts.poppins(
                  color: AppColors.appMainColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamed(context, RoutesName.SignInScreen);
                  },
              ),
            ],
          ),

          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
