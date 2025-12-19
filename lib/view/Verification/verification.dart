import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_textField.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
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
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                children: [
                  SizedBox(height: context.h(60)),
                  NormalText(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    titleText: "Verification",
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
                        'Enter the 6-digit code that we have sent to $emailDisplay',
                    subWeight: FontWeight.w500,
                    subColor: AppColors.whiteColor,
                    subAlign: TextAlign.center,
                    subSize: context.text(16),
                  ),
                  SizedBox(height: context.h(20)),
                  CustomTextField(
                    controller: verificationViewModel.emailController,
                    validatorType: "email",
                    label: "Email",
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(
                      color: AppColors.textFieldSubTitleColor,
                      fontWeight: FontWeight.w500,
                      fontSize: context.text(12),
                    ),
                    enabledBorderColor: AppColors.textFieldIconColor,
                    prefixIcon: const Icon(Icons.email),
                  ),
                  SizedBox(height: context.h(16)),
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
                  SizedBox(height: context.h(40)),
                  CustomButton(
                    onPressed: () => verificationViewModel.verify(context, formKey: _formKey),
                    height: context.h(48),
                    width: context.w(350),
                    gradient: AppColors.gradient,
                    text:
                        verificationViewModel.isLoading ? 'Verifying...' : 'Verify Account',
                    iconWidth: null,
                    iconHeight: null,
                    icon: null,
                  ),
                  if (verificationViewModel.isLoading) ...[
                    SizedBox(height: context.h(12)),
                    const Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ),
                  ],
                  SizedBox(height: context.h(40)),
                  CustomButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RoutesName.SignInScreen);
                    },
                    height: context.h(48),
                    width: context.w(350),
                    gradient: AppColors.gradient,
                    text: 'Back to Login',
                    iconWidth: null,
                    iconHeight: null,
                    icon: null,
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
