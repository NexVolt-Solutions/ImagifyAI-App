import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/align_text.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_textField.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';
import 'package:genwalls/Core/CustomWidget/password_text.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  bool? isChecked = false;

  int selectedIndex = -1;
  final List<String> items = [
    "1 or more numbers (0-9)",
    "1 or more English letters (A-Z, a,z)",
    "7 or more charactrers",
  ];
  @override
  Widget build(BuildContext context) {
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
            AlignText(
              text: 'Password must contain',
              fontWeight: FontWeight.w500,
              fontSize: context.text(16),
            ),
            SizedBox(height: context.h(4)),
            Column(
              children: List.generate(items.length, (index) {
                bool isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: PasswordText(
                    text: items[index],
                    icon: isSelected ? Icons.check : Icons.cancel,
                    iconColor: isSelected
                        ? AppColors.greenColor
                        : AppColors.grayColor,
                  ),
                );
              }),
            ),
            SizedBox(height: context.h(333)),
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
