import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_list_view.dart';
import 'package:genwalls/Core/CustomWidget/home_align.dart';
import 'package:genwalls/Model/viewModel/bottom_nav_screen_view_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
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
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30.w,
                          vertical: 10.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Muhammad,Shehzad 👋',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Ready to build your perfect wallpaper?',
                              style: GoogleFonts.poppins(
                                color: Color(0xFFA2A2A2),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Colors.white54),
                          hintText: 'Search Wallpapers...',
                          filled: true,
                          fillColor: Colors.black,
                          hintStyle: const TextStyle(color: Colors.white54),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                        ),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          dashPattern: [10, 5],
                          strokeWidth: 2,
                          radius: Radius.circular(16),
                          color: Colors.white,
                        ),
                        child: Container(
                          height: 300.h,
                          width: 350.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppAssets.dotConIcon,
                                height: 60.h,
                                width: 60.w,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                'Create Your Perfect\nWallpaper',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                'Use AI to generate stunning wallpapers tailored to your style. From abstract art to breathtaking landscapes.',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10.h),
                              CustomButton(
                                onPressed: () {
                                  final bottomNavProvider =
                                      Provider.of<BottomNavScreenViewModel>(
                                        context,
                                        listen: false,
                                      );

                                  bottomNavProvider.currentIndex = 1;
                                },
                                height: 47.h,
                                width: 212.w,
                                text: 'Generate wallpaper',
                                icon: null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    HomeAlign(text: 'Trending'),
                    SizedBox(height: 10.h),
                    CustomListView(image: AppAssets.conIcon),
                    SizedBox(height: 10.h),
                    HomeAlign(text: 'Nature'),
                    SizedBox(height: 10.h),
                    CustomListView(image: AppAssets.conIcon),
                    SizedBox(height: 10.h),
                    HomeAlign(text: '3D Render'),
                    SizedBox(height: 10.h),
                    CustomListView(image: AppAssets.conIcon),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
