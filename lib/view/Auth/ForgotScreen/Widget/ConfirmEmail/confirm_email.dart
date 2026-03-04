import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/custom_button.dart';
import 'package:imagifyai/Core/CustomWidget/custom_textField.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/confirm_email_view_model.dart';
import 'package:provider/provider.dart';

class ConfirmEmail extends StatelessWidget {
  const ConfirmEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfirmEmailViewModel>(
      builder: (context, viewModel, _) => Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                child: SvgPicture.asset(AppAssets.starLogo, fit: BoxFit.cover),
              ),
              SvgPicture.asset(AppAssets.imagifyaiLogo, fit: BoxFit.cover),
            ],
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: context.h(20)),
            children: [
              SizedBox(height: context.h(242)),
              Text(
                "Your Email",
                style: context.appTextStyles?.authTitlePrimary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.h(24)),
              CustomTextField(
                controller: viewModel.emailController,
                prefixIcon: Icon(Icons.email),
                validatorType: "email",
                hintText: 'Enter your email',
                hintStyle: context.appTextStyles?.authHintText,
                label: "Email",
                enabledBorderColor: context.colorScheme.onSurface,
              ),
              SizedBox(height: context.h(285)),
              CustomButton(
                onPressed: () =>
                    viewModel.navigateToForgotVerification(context),
                width: context.w(350),
                gradient: AppColors.gradient,
                text: 'Next',
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
