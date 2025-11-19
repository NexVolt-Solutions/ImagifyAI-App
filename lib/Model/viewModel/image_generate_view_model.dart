import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Model/utils/Routes/routes_name.dart';
import 'package:genwalls/view/ImageCreated/image_created_screen.dart';
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
            height: double.infinity.h,
            width: double.infinity.w,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularPercentIndicator(
                        radius: 100.0.r,
                        lineWidth: 15.0.w,
                        percent: 0.47,
                        center: Text(
                          '47%',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 40.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,

                        backgroundColor: Colors.grey,
                        progressColor: Colors.blue,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Creating your Masterpiece...',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16.sp,
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
                      color: Colors.white,
                      height: 50.h,
                      width: 50.w,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'For best results, keep prompts short.\n6 words or less',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
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
