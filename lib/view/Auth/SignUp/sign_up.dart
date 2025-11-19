import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/CustomWidget/align_text.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_textField.dart';
import 'package:genwalls/Core/CustomWidget/custom_text_rich.dart';
import 'package:genwalls/Core/CustomWidget/password_text.dart';
import 'package:genwalls/Model/utils/Routes/routes_name.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  int selectedIndex = -1; // koi select nahi by default

  final List<String> items = [
    "1 or more numbers (0-9)",
    "1 or more English letters (A-Z, a,z)",
    "7 or more charactrers",
  ];
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
                      'Sign Up',
                      style: GoogleFonts.poppins(
                        color: AppColors.appMainColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    AlignText(
                      text: 'Username',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                    SizedBox(height: 10.h),
                    CustomTextField(
                      hintText: 'Create your username',
                      validatorType: "name",
                      icon: Icon(Icons.person, color: Colors.grey),
                    ),
                    SizedBox(height: 10.h),
                    AlignText(
                      text: 'Email',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                    SizedBox(height: 10.h),
                    CustomTextField(
                      validatorType: "email",
                      hintText: 'Enter your email',
                      icon: Icon(Icons.email, color: Colors.grey),
                    ),
                    SizedBox(height: 10.h),
                    AlignText(
                      text: 'Create Password',

                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                    SizedBox(height: 10.h),
                    CustomTextField(
                      validatorType: "password",
                      hintText: 'Create your password',
                      icon: Icon(Icons.lock, color: Colors.grey),
                    ),
                    SizedBox(height: 10.h),
                    AlignText(
                      text: 'Password must contain',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                    SizedBox(height: 10.h),
                    Column(
                      children: List.generate(items.length, (index) {
                        bool isSelected = selectedIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: PasswordText(
                            text: items[index],
                            icon: isSelected ? Icons.check : Icons.cancel,
                            iconColor: isSelected ? Colors.green : Colors.grey,
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 10.h),
                    AlignText(
                      text: 'Create Password',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                    SizedBox(height: 10.h),
                    CustomTextField(
                      validatorType: "password",
                      hintText: 'Create your password',
                      icon: Icon(Icons.lock, color: Colors.grey),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey[300],
                            indent: 62,
                            endIndent: 10,
                          ),
                        ),
                        Text(
                          'or Continue ',
                          style: GoogleFonts.poppins(
                            color: AppColors.appMainColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey[300],
                            indent: 10,
                            endIndent: 62,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                      child: Container(
                        height: 47.9.h,
                        width: 350.w,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.w),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppAssets.googleIcon,
                              height: 23.h,
                              width: 23.w,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'Continue with Google',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    CustomTextRich(
                      text1: 'Already Have an Account? ',
                      text2: 'SignIn',
                      textSize1: 14.sp,
                      textSize2: 14.sp,
                    ),
                    SizedBox(height: 10.h),
                    Center(
                      child: CustomButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            RoutesName.BottomNavScreen,
                          );
                        },
                        height: 48.h,
                        width: 350.w,
                        text: 'Register',
                        icon: null,
                      ),
                    ),
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
