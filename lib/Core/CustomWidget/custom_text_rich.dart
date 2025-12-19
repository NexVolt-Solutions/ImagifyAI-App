import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextRich extends StatelessWidget {
  const CustomTextRich({
    super.key,
    this.text1,
    this.text2,
    this.textSize1,
    this.textSize2,
    this.onTap2,
  });
  final String? text1;
  final String? text2;
  final double? textSize1;
  final double? textSize2;
  final VoidCallback? onTap2;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.padSym(h: 10, v: 5),
      child: Align(
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: text1,
                style: GoogleFonts.poppins(
                    color: AppColors.textFieldSubTitleColor,
                  fontSize: textSize1 ?? textSize2 ??   context.text(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: text2,
                style: GoogleFonts.poppins(
                  color: AppColors.primeryColor,
                  fontSize: textSize2 ?? context.text(14),
                  fontWeight: FontWeight.w500,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    onTap2?.call();
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
