import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/custom_button.dart';
import 'package:imagifyai/Core/CustomWidget/custom_textField.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/forgot_password_view_model.dart';
import 'package:provider/provider.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  // Create formKey in widget state to ensure uniqueness per widget instance
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgotPasswordViewModel>(
      builder: (context, forgotPasswordViewModel, _) {
        return Scaffold(
          backgroundColor: context.backgroundColor,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(context.h(64)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(AppAssets.starLogo),
                SvgPicture.asset(AppAssets.imagifyaiLogo),
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: context.h(60)),
                      Text(
                        "Forgot Password",
                        style: context.appTextStyles?.authTitlePrimary,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: context.h(16)),
                      Text(
                        'Enter your email address and we\'ll send you a verification code to reset your password.',
                        style: context.appTextStyles?.authBodyRegular,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: context.h(24)),
                      CustomTextField(
                        controller: forgotPasswordViewModel.emailController,
                        prefixIcon: Icon(Icons.email),
                        validatorType: "email",
                        hintText: 'Enter your email',
                        hintStyle: context.appTextStyles?.authHintText,
                        label: "Email",
                        enabledBorderColor: context.colorScheme.onSurface,
                      ),
                      SizedBox(height: context.h(24)),
                      CustomButton(
                        onPressed: () => forgotPasswordViewModel.sendReset(
                          context,
                          formKey: _formKey,
                        ),
                        gradient: AppColors.gradient,
                        text: forgotPasswordViewModel.isLoading
                            ? 'Sending...'
                            : 'Send Reset Code',
                        isLoading: forgotPasswordViewModel.isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
