import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/view/Auth/SignIn/sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final defaultPinTheme = PinTheme(
    width: 50.w,
    height: 55.h,
    textStyle: TextStyle(
      fontSize: 20.sp,
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: Colors.grey),
    ),
  );
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
                    Text(
                      'Verification',
                      style: GoogleFonts.poppins(
                        color: AppColors.appMainColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Image.asset(AppAssets.verifIcon),
                    SizedBox(height: 10.h),
                    Text(
                      'Verify Your Account',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.h),

                    Text(
                      'Enter the 6-digit that we have sent to\nyahoo@gmail.com',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    Pinput(
                      length: 6,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: defaultPinTheme.copyWith(),
                      separatorBuilder: (index) => SizedBox(width: 5.w),
                      showCursor: true,
                      keyboardType: TextInputType.number,
                      onCompleted: (pin) {
                        // handle OTP completion
                      },
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      '02:30s',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    Center(
                      child: CustomButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignIn(),
                            ),
                          );
                        },
                        height: 48.h,
                        width: 350.w,
                        text: 'Register',
                        icon: null,
                      ),
                    ),
                    SizedBox(height: 20.h),
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
