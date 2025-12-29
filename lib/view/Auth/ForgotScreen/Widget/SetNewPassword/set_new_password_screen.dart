import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_textField.dart';
import 'package:genwalls/Core/CustomWidget/password_text.dart';
import 'package:genwalls/Core/theme/theme_extensions.dart';
import 'package:genwalls/viewModel/set_new_password_view_model.dart';
import 'package:provider/provider.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final List<String> items = const [
    "1 or more numbers (0-9)",
    "1 or more English letters (A-Z, a-z)",
    "7 or more characters",
  ];
  
  // Create unique formKey for this screen instance
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<SetNewPasswordViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: context.backgroundColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(AppAssets.starLogo,),
                SvgPicture.asset(AppAssets.genWallsLogo,),
                Align(
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
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                children: [
                  SizedBox(height: context.h(35)),
                  Text(
                    "Set New Password",
                    style: context.appTextStyles?.authTitlePrimary,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.h(24)),
                  CustomTextField(
                    controller: viewModel.passwordController,
                    prefixIcon: const Icon(Icons.lock),
                    validatorType: "password",
                    hintText: 'Enter new password',
                    hintStyle: context.appTextStyles?.authHintText,
                    label: "New Password",
                    enabledBorderColor: context.colorScheme.onSurface,
                  ),
                  SizedBox(height: context.h(24)),
                  CustomTextField(
                    controller: viewModel.confirmPasswordController,
                    prefixIcon: const Icon(Icons.lock),
                    validatorType: "password",
                    hintText: 'Confirm new password',
                    hintStyle: context.appTextStyles?.authHintText,
                    label: "Confirm Password",
                    enabledBorderColor: context.colorScheme.onSurface,
                  ),
                    SizedBox(height: context.h(24)),
                  Text(
                    "Password must contain",
                    style: context.appTextStyles?.authPasswordTitle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.h(4)),
                  Column(
                    children: List.generate(
                      items.length,
                      (index) => PasswordText(
                        text: items[index],
                        icon: Icons.check_circle,
                        iconColor: context.textColor,
                      ),
                    ),
                  ),
                  SizedBox(height: context.h(24)),
                  CustomButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () => viewModel.setNewPassword(context, _formKey),
                
                    gradient: AppColors.gradient,
                    text: viewModel.isLoading
                        ? 'Saving...'
                        : 'Save',
                  ),
                  SizedBox(height: context.h(32)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

