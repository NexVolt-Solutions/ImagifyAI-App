import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/custom_button.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/forgor_verification_view_model.dart';
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
      Provider.of<ForgorVerificationViewModel>(
        context,
        listen: false,
      ).setEmail(email);
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
          textStyle: context.appTextStyles?.authOTPText,
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: BorderRadius.circular(context.radius(8)),
            border: Border.all(color: context.theme.dividerColor),
          ),
        );
        return Scaffold(
          backgroundColor: context.backgroundColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(90),
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
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: context.h(20)),
              children: [
                SizedBox(height: context.h(35)),
                Text(
                  "Verification",
                  style: context.appTextStyles?.authTitlePrimary,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.h(32)),
                Image.asset(
                  AppAssets.verifIcon,
                  height: context.h(60),
                  width: context.w(60),
                  fit: BoxFit.contain,
                ),
                SizedBox(height: context.h(16)),
                Text(
                  "Verify Your Account",
                  style: context.appTextStyles?.authTitleWhite,
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: context.h(16)),
                Text(
                  email.isNotEmpty
                      ? 'Enter the 6-digit code that we have sent to $email'
                      : 'Enter the 6-digit code that we have sent to your email',
                  style: context.appTextStyles?.authSubtitleWhite,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.h(16)),
                Pinput(
                  length: 6,
                  controller: viewModel.codeController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: context.primaryColor),
                    ),
                  ),
                  separatorBuilder: (index) => SizedBox(width: context.w(10)),
                  showCursor: true,
                  keyboardType: TextInputType.number,
                  preFilledWidget: Center(
                    child: Text(
                      "-",
                      style: context.appTextStyles?.authOTPLarge,
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
                    style: context.appTextStyles?.authTimerText,
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  TextButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () => viewModel.resendCode(context),
                    child: Text(
                      'Resend Code',
                      style: context.appTextStyles?.authResendText,
                    ),
                  ),
                ],
                SizedBox(height: context.h(40)),
                CustomButton(
                  onPressed: () => viewModel.verify(context),
                  gradient: AppColors.gradient,
                  text: viewModel.isLoading ? 'Verifying...' : 'Verify',
                  isLoading: viewModel.isLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
