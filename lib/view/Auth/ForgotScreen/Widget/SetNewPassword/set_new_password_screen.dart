import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_textField.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';
import 'package:genwalls/Core/CustomWidget/password_text.dart';
import 'package:genwalls/viewModel/set_new_password_view_model.dart';
import 'package:provider/provider.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  int selectedIndex = -1;
  final List<String> items = const [
    "1 or more numbers (0-9)",
    "1 or more English letters (A-Z, a,z)",
    "7 or more charactrers",
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SetNewPasswordViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: AppColors.blackColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  child: SvgPicture.asset(AppAssets.starLogo, fit: BoxFit.cover),
                ),
                SvgPicture.asset(AppAssets.genWallsLogo, fit: BoxFit.cover),
              ],
            ),
          ),
          body: SafeArea(
            child: Form(
              key: viewModel.formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                children: [
                  SizedBox(height: context.h(25)),
                  NormalText(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    titleText: "Set New Password",
                    titleSize: context.text(20),
                    titleWeight: FontWeight.w600,
                    titleColor: AppColors.primeryColor,
                    titleAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.h(11)),
                  CustomTextField(
                    controller: viewModel.passwordController,
                    prefixIcon: const Icon(Icons.lock),
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
                  SizedBox(height: context.h(16)),
                  CustomTextField(
                    controller: viewModel.confirmPasswordController,
                    prefixIcon: const Icon(Icons.lock),
                    validatorType: "password",
                    hintText: 'Confirm new password',
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
                    children: List.generate(
                      items.length,
                      (index) => PasswordText(
                        text: items[index],
                        icon: Icons.check_circle,
                        iconColor: AppColors.grayColor,
                      ),
                    ),
                  ),
                  SizedBox(height: context.h(32)),
                  CustomButton(
                    onPressed: () => viewModel.setNewPassword(context),
                    height: context.h(48),
                    width: context.w(350),
                    gradient: AppColors.gradient,
                    text: viewModel.isLoading
                        ? 'Please wait...'
                        : 'Set New Password',
                    iconWidth: null,
                    iconHeight: null,
                    icon: null,
                  ),
                  if (viewModel.isLoading) ...[
                    SizedBox(height: context.h(12)),
                    const Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

