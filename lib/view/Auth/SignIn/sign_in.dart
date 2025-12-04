import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_textField.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
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
      backgroundColor: AppColors.blackColor,
      body: Scaffold(
        backgroundColor: AppColors.blackColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                child: Image.asset(AppAssets.starLogo, fit: BoxFit.cover),
              ),
              Image.asset(AppAssets.genWallsLogo, fit: BoxFit.cover),
            ],
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: context.h(20)),
            children: [
              SizedBox(height: context.h(25)),
              NormalText(
                crossAxisAlignment: CrossAxisAlignment.center,
                titleText: "Sign In",
                titleSize: context.text(20),
                titleWeight: FontWeight.w600,
                titleColor: AppColors.primeryColor,
                titleAlign: TextAlign.center,
              ),
              SizedBox(height: context.h(11)),
              CustomTextField(
                prefixIcon: Icon(Icons.email),
                validatorType: "email",
                hintText: 'Enter your email',
                hintStyle: TextStyle(
                  color: AppColors.textFieldSubTitleColor,
                  fontWeight: FontWeight.w500,
                  fontSize: context.text(12),
                ),
                label: "Email",
                enabledBorderColor: AppColors.textFieldIconColor,
              ),
              SizedBox(height: context.h(16)),
              CustomTextField(
                prefixIcon: Icon(Icons.lock),
                validatorType: "password",
                hintText: 'create your password',
                hintStyle: TextStyle(
                  color: AppColors.textFieldSubTitleColor,
                  fontWeight: FontWeight.w500,
                  fontSize: context.text(12),
                ),
                label: "Password",
                enabledBorderColor: AppColors.textFieldIconColor,
              ),
              SizedBox(height: context.h(24)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        checkColor: AppColors.greenColor,
                        side: BorderSide(color: AppColors.whiteColor),
                        fillColor: WidgetStateProperty.resolveWith<Color>((
                          states,
                        ) {
                          return AppColors.blackColor;
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
                          fontSize: context.text(14),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RoutesName.ConfirmEmailScreen,
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.poppins(
                        color: AppColors.primeryColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.h(333)),
              CustomButton(
                onPressed: () {
                  Navigator.pushNamed(context, RoutesName.BottomNavScreen);
                },
                height: context.h(48),
                width: context.w(350),
                gradient: AppColors.gradient,

                text: 'Register',
                iconWidth: null,
                iconHeight: null,
                icon: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
