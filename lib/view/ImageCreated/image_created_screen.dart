import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/CustomWidget/align_text.dart';
import 'package:genwalls/Core/CustomWidget/icon_custom_button.dart';
import 'package:genwalls/Model/viewModel/home_view_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ImageCreatedScreen extends StatefulWidget {
  const ImageCreatedScreen({super.key});

  @override
  State<ImageCreatedScreen> createState() => _ImageCreatedScreenState();
}

class _ImageCreatedScreenState extends State<ImageCreatedScreen> {
  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);

    return Scaffold(
      body: Container(
        height: double.infinity.h,
        width: double.infinity.w,
        color: Colors.black,
        child: Stack(
          children: [
            Positioned(
              top: 30.h,
              left: 0.w,
              right: 0.w,
              child: Center(
                child: Image.asset(AppAssets.starLogo, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 30.h,
              left: 0.w,
              right: 0.w,
              child: Center(
                child: Image.asset(
                  AppAssets.genWallsLogo,
                  height: 20.h,
                  width: 120.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              top: 70.h,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AlignText(text: 'Result'),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Container(
                        height: 0.8 * MediaQuery.of(context).size.width,
                        width: 350,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.asset(
                            AppAssets.conIcon,
                            width: 110.w,
                            height: 95.h,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                      child: Container(
                        height: 124.h,
                        width: 350.w,
                        decoration: BoxDecoration(
                          color: Color(0xFF17171D),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 15.0.w,
                                vertical: 12.h,
                              ),
                              child: Text(
                                '3D cartoon-style illustration of a young girl with Día de los Muertos face paint, wearing casual clothes, standing in a glowing.',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Image.asset(
                                  AppAssets.copyIcon,

                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconCustomButton(
                            height: 48.h,
                            width: 150.w,
                            icon: AppAssets.refreshIcon,
                            text: 'Recreate',
                          ),
                          IconCustomButton(
                            height: 48.h,
                            width: 150.w,
                            icon: AppAssets.downloadIcon,
                            text: 'Download',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 30.h,
              left: 20.w,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
