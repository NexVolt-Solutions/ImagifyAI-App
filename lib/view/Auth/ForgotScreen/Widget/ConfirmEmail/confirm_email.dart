import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_textField.dart';
import 'package:genwalls/Core/theme/theme_extensions.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';

class ConfirmEmail extends StatefulWidget {
  const ConfirmEmail({super.key});

  @override
  State<ConfirmEmail> createState() => _ConfirmEmailState();
}

class _ConfirmEmailState extends State<ConfirmEmail> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: context.backgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(90),
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
                prefixIcon: Icon(Icons.email),
                validatorType: "email",
                hintText: 'Enter your email',
                hintStyle: context.appTextStyles?.authHintText,
                label: "Email",
                enabledBorderColor: context.colorScheme.onSurface,
              ),
              SizedBox(height: context.h(285)),
              CustomButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RoutesName.ForgotVerificationScreen,
                  );
                },
                 
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
    );
  }
}
