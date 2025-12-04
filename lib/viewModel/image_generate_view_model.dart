import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ImageGenerateViewModel extends ChangeNotifier {
  int selectedIndex = -1;

  final List<Map<String, dynamic>> sizes = [
    {'text1': '1:1', 'text2': 'Square'},
    {'text1': '16:9', 'text2': 'Widescreen'},
    {'text1': '9:16', 'text2': 'Portrait'},
  ];
  void showStyledNumberDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      barrierLabel: "Dismiss",
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.white12,
          body: SizedBox(
            height: context.h(double.infinity),
            width: context.w(double.infinity),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularPercentIndicator(
                        radius: context.radius(100),
                        lineWidth: context.w(15),
                        percent: 0.47,
                        center: Text(
                          '47%',
                          style: GoogleFonts.poppins(
                            color: AppColors.whiteColor,
                            fontSize: context.text(40),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,

                        backgroundColor: Colors.grey,
                        progressColor: AppColors.primeryColor,
                      ),
                      SizedBox(height: context.h(20)),
                      Text(
                        'Creating your Masterpiece...',
                        style: GoogleFonts.poppins(
                          color: AppColors.whiteColor,
                          fontSize: context.text(16),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    Image.asset(
                      AppAssets.imageIconPlus,
                      color: AppColors.whiteColor,
                      height: context.h(50),
                      width: context.w(50),
                    ),
                    SizedBox(height: context.h(10)),
                    Text(
                      'For best results, keep prompts short.\n6 words or less',
                      style: GoogleFonts.poppins(
                        color: AppColors.whiteColor,
                        fontSize: context.text(16),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.h(20)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushNamed(context, RoutesName.ImageCreatedScreen);
    });
  }
}
