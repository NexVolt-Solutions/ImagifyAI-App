import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
  import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
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
    late final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<SignUpViewModel>(
      builder: (context, signUpViewModel, _) {
        return Scaffold(
          backgroundColor: AppColors.blackColor,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(context.h(100)),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: context.h(20)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(AppAssets.genWallsLogo, fit: BoxFit.cover),
                  SvgPicture.asset(AppAssets.starLogo, fit: BoxFit.cover),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                children: [
                   NormalText(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    titleText: "Sign Up",
                    titleSize: context.text(20),
                    titleWeight: FontWeight.w600,
                    titleColor: AppColors.primeryColor,
                    titleAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.h(16)),
                  GestureDetector(
                    onTap: () => signUpViewModel.pickImage(),
                    child: Container(
                      height: context.h(120),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.blackColor,
                        border: Border.all(color: AppColors.textFieldIconColor),
                        borderRadius: BorderRadius.circular(context.radius(12)),
                      ),
                      child: signUpViewModel.profileImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                context.radius(10),
                              ),
                              child: Image.file(
                                File(signUpViewModel.profileImage!.path),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppAssets.cameraIconPlus,
                                  height: context.h(40),
                                ),
                                SizedBox(height: context.h(8)),
                                Text(
                                  'Add profile image',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textFieldSubTitleColor,
                                    fontSize: context.text(12),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: context.h(16)),
                  CustomTextField(
                    controller: signUpViewModel.usernameController,
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
                    controller: signUpViewModel.emailController,
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
                    controller: signUpViewModel.passwordController,
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
                    onChanged: (value) {
                      signUpViewModel.validatePassword();
                    },
                  ),
                  SizedBox(height: context.h(16)),
                  CustomTextField(
                    controller: signUpViewModel.confirmPasswordController,
                    prefixIcon: Icon(Icons.lock),
                    validatorType: "password",
                    hintText: 'confirm your password',
                    hintStyle: TextStyle(
                      color: AppColors.textFieldSubTitleColor,
                      fontWeight: FontWeight.w500,
                      fontSize: context.text(12),
                    ),
                    label: "Confirm Password",
                    enabledBorderColor: AppColors.textFieldIconColor,
                  ),
                  SizedBox(height: context.h(20)),
                  NormalText(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    titleText: "Password must contain",
                    titleSize: context.text(16),
                    titleWeight: FontWeight.w500,
                    titleColor: AppColors.whiteColor,
                    titleAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.h(4)),
                  Column(
                    children: List.generate(signUpViewModel.items.length, (
                      index,
                    ) {
                      final isRequirementMet = signUpViewModel.isRequirementMet(index);
                      return PasswordText(
                        text: signUpViewModel.items[index],
                        icon: isRequirementMet ? Icons.check_circle : Icons.cancel,
                        iconColor: isRequirementMet
                            ? AppColors.greenColor
                            : AppColors.grayColor,
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
                      NormalText(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        titleText: "or Continue ",
                        titleSize: context.text(14),
                        titleWeight: FontWeight.w500,
                        titleColor: AppColors.primeryColor,
                        titleAlign: TextAlign.center,
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
                  Container(
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
                        SizedBox(width: context.w(8)),
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
                
                   SizedBox(height: context.h(20)),
                  CustomButton(
                    onPressed: () => signUpViewModel.register(context, formKey: _formKey),
                    height: context.h(48),
                    width: context.w(350),
                    gradient: AppColors.gradient,
                    text: signUpViewModel.isLoading
                        ? 'Creating your account...'
                        : 'Create Account',
                    iconWidth: null,
                    iconHeight: null,
                    icon: null,
                  ),
                  if (signUpViewModel.isLoading) ...[
                    SizedBox(height: context.h(12)),
                    const Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ),
                  ],
                    SizedBox(height: context.h(16)),
                  CustomTextRich(
                    text1: 'Already Have an Account? ',
                    text2: 'SignIn',
                    textSize1: context.text(14),
                    textSize2: context.text(14),
                    onTap2: () {  
                      Navigator.pushNamed(context, RoutesName.SignInScreen);
                    },
                  ),                   SizedBox(height: context.h(20)),

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
