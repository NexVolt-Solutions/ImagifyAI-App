import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';
import 'package:genwalls/viewModel/verification_view_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  bool _initialized = false;
  // Create formKey in widget state to ensure uniqueness per widget instance
  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final emailArg = ModalRoute.of(context)?.settings.arguments;
    if (emailArg is String && emailArg.isNotEmpty) {
      context.read<VerificationViewModel>().setEmail(emailArg);
    }
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VerificationViewModel>(
      builder: (context, verificationViewModel, _) {
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

        final emailDisplay = verificationViewModel.emailController.text.isNotEmpty
            ? verificationViewModel.emailController.text
            : 'your email';

        return Scaffold(
          backgroundColor: AppColors.blackColor,
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(context.h(64)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  AppAssets.starLogo,
                  fit: BoxFit.contain,
                  placeholderBuilder: (context) => const SizedBox.shrink(),
                ),
                SvgPicture.asset(
                  AppAssets.genWallsLogo,
                  fit: BoxFit.contain,
                  placeholderBuilder: (context) => const SizedBox.shrink(),
                ),
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
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal  : context.h(20)),
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
                SizedBox(height: context.h(24)),
                  Center(
                    child: Image.asset(
                      AppAssets.verifIcon,
                      fit: BoxFit.contain,
                     
                    ),
                  ),
                  SizedBox(height: context.h(24)),
                  NormalText(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    titleText: "Verify Your Account",
                    titleSize: context.text(20),
                    titleWeight: FontWeight.w600,
                    titleColor: AppColors.whiteColor,
                    titleAlign: TextAlign.start,
                  ),
                   SizedBox(height: context.h(24)),
                  NormalText(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    subText:
                        'Enter the 6-digit code that we have sent to $emailDisplay',
                    subWeight: FontWeight.w400,
                    subColor: AppColors.whiteColor,
                    subAlign: TextAlign.center,
                    subSize: context.text(14),
                  ),
                 
                  SizedBox(height: context.h(24)),
                  Pinput(
                    length: 6,
                    controller: verificationViewModel.codeController,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!,
                    ),
                    separatorBuilder: (index) => SizedBox(width: context.w(10)),
                    showCursor: true,
                    keyboardType: TextInputType.number,
                    onCompleted: (pin) {
                      verificationViewModel.codeController.text = pin;
                    },
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
                  ),
                  SizedBox(height: context.h(24)),
                  if (!verificationViewModel.canResend) ...[
                    Text(
                      verificationViewModel.timerText,
                      style: GoogleFonts.poppins(
                        color: AppColors.whiteColor,
                        fontSize: context.text(16),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: verificationViewModel.isLoading
                          ? null
                          : () => verificationViewModel.resendCode(context),
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
                    SizedBox(height: context.h(32)),
                  CustomButton(
                    onPressed: () => verificationViewModel.verify(context, formKey: _formKey),
                     
                     gradient: AppColors.gradient,
                    text:
                        verificationViewModel.isLoading ? 'Verifying...' : 'Verify Account',
                 
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
