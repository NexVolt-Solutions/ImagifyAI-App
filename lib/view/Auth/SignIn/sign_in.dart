import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/CustomWidget/align_text.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_textField.dart';
import 'package:genwalls/Model/utils/Routes/routes_name.dart';
import 'package:google_fonts/google_fonts.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool? isChecked = true;

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
                      'Sign In',
                      style: GoogleFonts.poppins(
                        color: AppColors.appMainColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isChecked,

                            checkColor: Colors.green,

                            side: BorderSide(color: Colors.white, width: 1),

                            fillColor: WidgetStateProperty.resolveWith<Color>((
                              states,
                            ) {
                              return Colors.black;
                            }),

                            onChanged: (value) {
                              setState(() {
                                isChecked = value;
                              });
                            },
                          ),
                          Text(
                            'Remember me',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 52.w),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                RoutesName.ForgotScreen,
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.poppins(
                                color: AppColors.appMainColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 300.h),
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
                        text: 'Login',
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
