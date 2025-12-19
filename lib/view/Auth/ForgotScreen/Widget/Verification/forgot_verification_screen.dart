import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
  import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class ForgotVerificationScreen extends StatefulWidget {
  const ForgotVerificationScreen({super.key});

  @override
  State<ForgotVerificationScreen> createState() =>
      _ForgotVerificationScreenState();
}

class _ForgotVerificationScreenState extends State<ForgotVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: context.h(45),
      height: context.h(45),
      textStyle: TextStyle(
        fontSize: context.text(14),
        color: AppColors.whiteColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        color: AppColors.blackColor,
        borderRadius: BorderRadius.circular(context.radius(8)),
        border: Border.all(color: AppColors.grayColor),
      ),
    );
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
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: context.h(20)),
          children: [
            SizedBox(height: context.h(60)),
            NormalText(
              crossAxisAlignment: CrossAxisAlignment.center,
              titleText: "for Verification",
              titleSize: context.text(20),
              titleWeight: FontWeight.w600,
              titleColor: AppColors.primeryColor,
              titleAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(16)),
            Image.asset(
              AppAssets.verifIcon,
              height: context.h(60),
              width: context.w(60),
              fit: BoxFit.contain,
            ),
            SizedBox(height: context.h(16)),
            NormalText(
              crossAxisAlignment: CrossAxisAlignment.center,
              titleText: "Verify Your Account",
              titleSize: context.text(20),
              titleWeight: FontWeight.w600,
              titleColor: AppColors.whiteColor,
              titleAlign: TextAlign.start,
            ),
            SizedBox(height: context.h(16)),
            NormalText(
              crossAxisAlignment: CrossAxisAlignment.center,
              subText:
                  'Enter the 6-digit that we have sent to  yahoo@gmail.com',
              subWeight: FontWeight.w500,
              subColor: AppColors.whiteColor,
              subAlign: TextAlign.center,
              subSize: context.text(16),
            ),
            SizedBox(height: context.h(16)),
            Pinput(
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!,
              ),
              separatorBuilder: (index) => SizedBox(width: context.w(10)),
              showCursor: true,
              keyboardType: TextInputType.number,
              preFilledWidget: Center(
                child: Text(
                  "-",
                  style: TextStyle(
                    fontSize: context.text(20),
                    color: AppColors.grayColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              onCompleted: (pin) {
                print(pin);
              },
            ),
            SizedBox(height: context.h(16)),
            Text(
              '02:30s',
              style: GoogleFonts.poppins(
                color: AppColors.whiteColor,
                fontSize: context.text(16),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(257)),
            CustomButton(
              onPressed: () {
                Navigator.pushNamed(context, RoutesName.AccountCreatedScreen);
              },
              height: context.h(48),
              width: context.w(350),
              gradient: AppColors.gradient,
              text: 'Verify',
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
