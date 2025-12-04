import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/align_text.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_textField.dart';
import 'package:genwalls/Core/CustomWidget/custom_text_rich.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';
import 'package:genwalls/Core/CustomWidget/password_text.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/viewModel/sign_up_view_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    final signUpViewModel = Provider.of<SignUpViewModel>(context);
    return Scaffold(
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
              titleText: "Sign Up",
              titleSize: context.text(20),
              titleWeight: FontWeight.w600,
              titleColor: AppColors.primeryColor,
              titleAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(11)),
            CustomTextField(
              prefixIcon: Icon(Icons.person),
              validatorType: "name",
              hintText: 'Create your username',
              hintStyle: TextStyle(
                color: AppColors.textFieldSubTitleColor,
                fontWeight: FontWeight.w500,
                fontSize: context.text(12),
              ),
              label: "User Name",
              enabledBorderColor: AppColors.textFieldIconColor,
            ),
            SizedBox(height: context.h(16)),
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
              label: "Confirm Password",
              enabledBorderColor: AppColors.textFieldIconColor,
            ),
            SizedBox(height: context.h(20)),
            AlignText(
              text: 'Password must contain',
              fontWeight: FontWeight.w500,
              fontSize: context.text(16),
            ),
            SizedBox(height: context.h(4)),
            Column(
              children: List.generate(signUpViewModel.items.length, (index) {
                bool isSelected = signUpViewModel.selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      signUpViewModel.selectedIndex = index;
                    });
                  },
                  child: PasswordText(
                    text: signUpViewModel.items[index],
                    icon: isSelected ? Icons.check : Icons.cancel,
                    iconColor: isSelected
                        ? AppColors.greenColor
                        : AppColors.grayColor,
                  ),
                );
              }),
            ),
            SizedBox(height: context.h(24)),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    thickness: 1,
                    color: AppColors.grayColor,
                    indent: 62,
                    endIndent: 10,
                  ),
                ),
                Text(
                  'or Continue ',
                  style: GoogleFonts.poppins(
                    color: AppColors.primeryColor,
                    fontSize: context.text(14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Divider(
                    thickness: 1,
                    color: AppColors.grayColor,
                    indent: 10,
                    endIndent: 62,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(24)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.h(20)),
              child: Container(
                height: context.h(47.9),
                width: context.w(350),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.whiteColor),
                  borderRadius: BorderRadius.circular(
                    context.radius(context.radius(8)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.googleIcon,
                      height: context.h(23.94),
                      width: context.w(23.94),
                    ),
                    SizedBox(width: context.w(0.8)),
                    Text(
                      'Continue with Google',
                      style: GoogleFonts.poppins(
                        color: AppColors.grayColor,
                        fontSize: context.text(14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.h(24)),
            CustomTextRich(
              text1: 'Already Have an Account? ',
              text2: 'SignIn',
              textSize1: context.text(14),
              textSize2: context.text(14),
            ),
            SizedBox(height: context.h(8.06)),
            SizedBox(height: context.h(20)),
            CustomButton(
              onPressed: () {
                Navigator.pushNamed(context, RoutesName.VerificationScreen);
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
    );
  }
}
