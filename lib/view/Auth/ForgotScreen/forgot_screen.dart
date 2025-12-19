import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_textField.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';
import 'package:genwalls/Core/CustomWidget/password_text.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/viewModel/forgot_password_view_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  int selectedIndex = -1;
  final List<String> items = const [
    "1 or more numbers (0-9)",
    "1 or more English letters (A-Z, a,z)",
    "7 or more charactrers",
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgotPasswordViewModel>(
      builder: (context, forgotPasswordViewModel, _) {
        return Scaffold(
          backgroundColor: AppColors.blackColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                    child: SvgPicture.asset(AppAssets.starLogo, fit: BoxFit.cover),
                ),
                SvgPicture.asset(AppAssets.genWallsLogo, fit: BoxFit.cover),
              ],
            ),
          ),
          body: SafeArea(
            child: Form(
              key: forgotPasswordViewModel.formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                children: [
                  SizedBox(height: context.h(25)),
                  NormalText(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    titleText: "Forgot Password",
                    titleSize: context.text(20),
                    titleWeight: FontWeight.w600,
                    titleColor: AppColors.primeryColor,
                    titleAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.h(11)),
                  CustomTextField(
                    controller: forgotPasswordViewModel.emailController,
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
                    hintText: 'Enter new password',
                    hintStyle: TextStyle(
                      color: AppColors.textFieldSubTitleColor,
                      fontWeight: FontWeight.w500,
                      fontSize: context.text(12),
                    ),
                    label: "New Password",
                    enabledBorderColor: AppColors.textFieldIconColor,
                  ),
                  SizedBox(height: context.h(24)),
                  Text(
                    'Password must contain',
                    style: GoogleFonts.poppins(
                      color: AppColors.whiteColor,
                      fontSize: context.text(16),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: context.h(4)),
                  Column(
                    children: List.generate(items.length, (index) {
                      final isSelected = selectedIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: PasswordText(
                          text: items[index],
                          icon: isSelected ? Icons.check : Icons.cancel,
                          iconColor:
                              isSelected ? AppColors.greenColor : AppColors.grayColor,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: context.h(24)),
                  Text(
                    'We will send a password reset link/code to your email.',
                    style: GoogleFonts.poppins(
                      color: AppColors.grayColor,
                      fontSize: context.text(13),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.h(32)),
                  CustomButton(
                    onPressed: () => forgotPasswordViewModel.sendReset(context),
                    height: context.h(48),
                    width: context.w(350),
                    gradient: AppColors.gradient,
                    text: forgotPasswordViewModel.isLoading
                        ? 'Please wait...'
                        : 'Send Reset Link',
                    iconWidth: null,
                    iconHeight: null,
                    icon: null,
                  ),
                  if (forgotPasswordViewModel.isLoading) ...[
                    SizedBox(height: context.h(12)),
                    const Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ),
                  ],
                  SizedBox(height: context.h(24)),
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
                  SizedBox(height: context.h(16)),
                  CustomButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RoutesName.SignInScreen);
                    },
                    height: context.h(48),
                    width: context.w(350),
                    gradient: AppColors.gradient,
                    text: 'Back to Login',
                    iconWidth: null,
                    iconHeight: null,
                    icon: null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
