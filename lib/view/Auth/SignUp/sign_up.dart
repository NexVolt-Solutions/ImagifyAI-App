import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_textField.dart';
import 'package:genwalls/Core/CustomWidget/custom_text_rich.dart';
import 'package:genwalls/Core/CustomWidget/password_text.dart';
import 'package:genwalls/Core/theme/theme_extensions.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/viewModel/sign_up_view_model.dart';
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
          backgroundColor: context.backgroundColor,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(context.h(64)),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: context.h(20)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(AppAssets.genWallsLogo, fit: BoxFit.cover),
                  SvgPicture.asset(AppAssets.starLogo, fit: BoxFit.cover),  Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: context.h(8)),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).iconTheme.color,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      splashRadius: 20,
                    ),
                  ),
                ),
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
                  Text(
                    "Sign Up",
                    style: context.appTextStyles?.authTitlePrimary,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.h(16)),
                  Center(
                    child: GestureDetector(
                      onTap: () => signUpViewModel.pickImage(),
                      child: Container(
                        height: context.h(180),
                        width: context.h(180),
                        decoration: BoxDecoration(  
                          color: ThemeColors.containerColor(context),
                          border: Border.all(color: context.colorScheme.onSurface),
                          shape: BoxShape.circle,
                        ),
                        child: signUpViewModel.profileImage != null
                            ? ClipOval(
                                child: Image.file(
                                  File(signUpViewModel.profileImage!.path),
                                  fit: BoxFit.cover,
                                  width: context.h(180),
                                  height: context.h(180),
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppAssets.cameraIconPlus,
                                    height: context.h(42),
                                    width: context.w(42),
                                  ),
                                  SizedBox(height: context.h(8)),
                                  Text(
                                    'Add profile image',
                                    style: context.appTextStyles?.authHintText,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.h(16)),
                  CustomTextField(
                    controller: signUpViewModel.usernameController,
                    prefixIcon: Icon(Icons.person),
                    validatorType: "name",
                    hintText: 'Create your username',
                    hintStyle: context.appTextStyles?.authHintText,
                    label: "User Name",
                    enabledBorderColor: context.colorScheme.onSurface,
                  ),
                  SizedBox(height: context.h(24)),
                  CustomTextField(
                    controller: signUpViewModel.emailController,
                    prefixIcon: Icon(Icons.email),
                    validatorType: "email",
                    hintText: 'Enter your email',
                    hintStyle: context.appTextStyles?.authHintText,
                    label: "Email",
                    enabledBorderColor: context.colorScheme.onSurface,
                  ),
                  SizedBox(height: context.h(24)),
                  CustomTextField(
                    controller: signUpViewModel.passwordController,
                    prefixIcon: Icon(Icons.lock),
                    validatorType: "password",
                    hintText: 'create your password',
                    hintStyle: context.appTextStyles?.authHintText,
                    label: "Password",
                    enabledBorderColor: context.colorScheme.onSurface,
                    onChanged: (value) {
                      signUpViewModel.validatePassword();
                    },
                  ),
                  SizedBox(height: context.h(24)),    
                  CustomTextField(
                    controller: signUpViewModel.confirmPasswordController,
                    prefixIcon: Icon(Icons.lock),
                    validatorType: "password",
                    hintText: 'confirm your password',
                    hintStyle: context.appTextStyles?.authHintText,
                    label: "Confirm Password",
                    enabledBorderColor: context.colorScheme.onSurface,
                  ),
                  SizedBox(height: context.h(20)),
                  Text(
                    "Password must contain",
                    style: context.appTextStyles?.authPasswordTitle,
                    textAlign: TextAlign.center,
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
                          color: context.theme.dividerColor,
                          indent: 62,
                          endIndent: 10,
                        ),
                      ),
                      Text(
                        "or Continue ",
                        style: context.appTextStyles?.authSubtitlePrimary,
                        textAlign: TextAlign.center,
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: context.theme.dividerColor,
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
                      border: Border.all(color: context.colorScheme.onSurface),
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
                          style: context.appTextStyles?.authGoogleButton,
                        ),
                      ],
                    ),
                  ),
                
                   SizedBox(height: context.h(20)),
                  CustomButton(
                    onPressed: () => signUpViewModel.register(context, formKey: _formKey),
                     
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
                    text1: 'Already Have an Account?',
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
