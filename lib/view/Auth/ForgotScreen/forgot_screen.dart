import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/CustomWidget/align_text.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_textField.dart';
import 'package:genwalls/Core/CustomWidget/password_text.dart';
import 'package:genwalls/Model/utils/Routes/routes_name.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
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
                      'Forgot Password',
                      style: GoogleFonts.poppins(
                        color: AppColors.appMainColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 10.h),
                    AlignText(text: 'Email'),
                    SizedBox(height: 10.h),
                    CustomTextField(
                      validatorType: "email",
                      hintText: 'Enter your email',
                      icon: Icon(Icons.email, color: Colors.grey),
                    ),
                    SizedBox(height: 10.h),
                    AlignText(text: 'Create Password'),
                    SizedBox(height: 10.h),
                    CustomTextField(
                      validatorType: "password",
                      hintText: 'Create your password',
                      icon: Icon(Icons.lock, color: Colors.grey),
                    ),

                    SizedBox(height: 10.h),
                    AlignText(text: 'Password must contain'),
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
                    // PasswordText(
                    //   text: '1 or more numbers (0-9)',
                    //   icon: Icons.close,
                    // ),
                    // PasswordText(
                    //   text: '1 or more English letters (A-Z, a,z)',
                    //   icon: Icons.check,
                    // ),
                    // PasswordText(
                    //   text: '7 or more charactrers',
                    //   icon: Icons.close,
                    // ),
                    SizedBox(height: 10.h),

                    SizedBox(height: 250.h),
                    Center(
                      child: CustomButton(
                        onPressed: () {
                          Navigator.pushNamed(context, RoutesName.SignInScreen);
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
