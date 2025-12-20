import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';
import 'package:genwalls/viewModel/forgor_verification_view_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class ForgotVerificationScreen extends StatefulWidget {
  const ForgotVerificationScreen({super.key});

  @override
  State<ForgotVerificationScreen> createState() =>
      _ForgotVerificationScreenState();
}

class _ForgotVerificationScreenState extends State<ForgotVerificationScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set email in view model when screen loads
    final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    if (email.isNotEmpty) {
      Provider.of<ForgorVerificationViewModel>(context, listen: false).setEmail(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    
    return Consumer<ForgorVerificationViewModel>(
      builder: (context, viewModel, _) {
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
                    color: AppColors.whiteColor,
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
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: context.h(20)),
          children: [
            SizedBox(height: context.h(35)),
            NormalText(
              crossAxisAlignment: CrossAxisAlignment.center,
              titleText: "Verification",
              titleSize: context.text(20),
              titleWeight: FontWeight.w600,
              titleColor: AppColors.primeryColor,
              titleAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(32)),
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
              subText: email.isNotEmpty
                  ? 'Enter the 6-digit code that we have sent to $email'
                  : 'Enter the 6-digit code that we have sent to your email',
              subWeight: FontWeight.w400,
              subColor: AppColors.whiteColor,
              subAlign: TextAlign.center,
              subSize: context.text(14),
            ),
            SizedBox(height: context.h(16)),
            Pinput(
              length: 6,
              controller: viewModel.codeController,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color: AppColors.primeryColor),
                ),
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
                viewModel.verify(context);
              },
            ),
            SizedBox(height: context.h(16)),
            if (!viewModel.canResend) ...[
              Text(
                viewModel.timerText,
                style: GoogleFonts.poppins(
                  color: AppColors.whiteColor,
                  fontSize: context.text(16),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              TextButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () => viewModel.resendCode(context),
                child: Text(
                  'Resend Code',
                  style: GoogleFonts.poppins(
                    color: AppColors.primeryColor,
                    fontSize: context.text(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            SizedBox(height: context.h(40)),
            CustomButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () => viewModel.verify(context),
               
              gradient: AppColors.gradient,
              text: viewModel.isLoading ? 'Verifying...' : 'Verify',
           
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}
