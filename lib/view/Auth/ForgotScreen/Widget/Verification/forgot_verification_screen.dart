import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';
import 'package:imagifyai/Core/CustomWidget/custom_button.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/forgot_verification_view_model.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

/// Standard layout and OTP pin sizing (same as main Verification screen).
class _ForgotVerificationLayout {
  _ForgotVerificationLayout._();

  static const double screenPaddingH = 24;
  static const double sectionSpacing = 24;
  static const double buttonTop = 32;
  static const double appBarHeight = 65;
  static const double pinRadius = 12;
  static const double pinBorderWidth = 1.0;
  static const double pinBorderWidthFocused = 2.0;
  static const double pinSize = 48;
  static const double pinSpacing = 12;
  static const double backIconSize = 24;
  static const double backPadding = 12;
}

class ForgotVerificationScreen extends StatefulWidget {
  const ForgotVerificationScreen({super.key});

  @override
  State<ForgotVerificationScreen> createState() =>
      _ForgotVerificationScreenState();
}

class _ForgotVerificationScreenState extends State<ForgotVerificationScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final vm = context.read<ForgotVerificationViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      vm.onScreenEnter(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<ForgotVerificationViewModel>(
      builder: (context, vm, _) {
        final greyBorderColor = colorScheme.onSurface.withOpacity(0.42);
        final focusedBorderColor = colorScheme.primary;
        final filledBorderColor = Colors.white;
        final errorBorderColor = colorScheme.error;

        final basePinTheme = PinTheme(
          width: _ForgotVerificationLayout.pinSize,
          height: _ForgotVerificationLayout.pinSize,
          textStyle: context.appTextStyles?.authOTPText,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(
              _ForgotVerificationLayout.pinRadius,
            ),
            border: Border.all(
              color: greyBorderColor,
              width: _ForgotVerificationLayout.pinBorderWidth,
            ),
          ),
        );

        final defaultPinTheme = basePinTheme;
        final focusedPinTheme = basePinTheme.copyWith(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(
              _ForgotVerificationLayout.pinRadius,
            ),
            border: Border.all(
              color: focusedBorderColor,
              width: _ForgotVerificationLayout.pinBorderWidthFocused,
            ),
          ),
        );
        final filledPinTheme = basePinTheme.copyWith(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(
              _ForgotVerificationLayout.pinRadius,
            ),
            border: Border.all(
              color: filledBorderColor,
              width: _ForgotVerificationLayout.pinBorderWidth,
            ),
          ),
        );
        final errorPinTheme = basePinTheme.copyWith(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(
              _ForgotVerificationLayout.pinRadius,
            ),
            border: Border.all(
              color: errorBorderColor,
              width: _ForgotVerificationLayout.pinBorderWidthFocused,
            ),
          ),
        );

        final hasError = vm.errorMessage != null;
        final effectiveDefault = hasError ? errorPinTheme : defaultPinTheme;
        final effectiveFocused = hasError ? errorPinTheme : focusedPinTheme;
        final effectiveFilled = hasError ? errorPinTheme : filledPinTheme;

        return Scaffold(
          backgroundColor: context.backgroundColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(
              _ForgotVerificationLayout.appBarHeight,
            ),
            child: Container(
              color: context.backgroundColor,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    AppAssets.starLogo,
                    fit: BoxFit.contain,
                    placeholderBuilder: (_) => const SizedBox.shrink(),
                  ),
                  SvgPicture.asset(
                    AppAssets.imagifyaiLogo,
                    fit: BoxFit.contain,
                    placeholderBuilder: (_) => const SizedBox.shrink(),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: colorScheme.onSurface,
                        size: _ForgotVerificationLayout.backIconSize,
                      ),
                      padding: const EdgeInsets.all(
                        _ForgotVerificationLayout.backPadding,
                      ),
                      style: IconButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _ForgotVerificationLayout.screenPaddingH,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: context.h(32)),
                    Center(
                      child: Image.asset(
                        AppAssets.forgotIcon,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(
                      height: context.h(
                        _ForgotVerificationLayout.sectionSpacing,
                      ),
                    ),
                    Text(
                      'Verify Your Account',
                      style: context.appTextStyles?.authTitleWhite,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: context.h(
                        _ForgotVerificationLayout.sectionSpacing,
                      ),
                    ),
                    Text(
                      'Enter the 6-digit code that we have sent to ${vm.emailDisplay}',
                      style: context.appTextStyles?.authBodyRegular,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: context.h(
                        _ForgotVerificationLayout.sectionSpacing,
                      ),
                    ),
                    Pinput(
                      length: 6,
                      controller: vm.codeController,
                      defaultPinTheme: effectiveDefault,
                      focusedPinTheme: effectiveFocused,
                      submittedPinTheme: effectiveFilled,
                      followingPinTheme: effectiveDefault,
                      separatorBuilder: (_) => SizedBox(
                        width: context.w(_ForgotVerificationLayout.pinSpacing),
                      ),
                      showCursor: true,
                      keyboardType: TextInputType.number,
                      onCompleted: (pin) {
                        vm.codeController.text = pin;
                      },
                      preFilledWidget: Center(
                        child: Text(
                          '−',
                          style: context.appTextStyles?.authOTPLarge,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: context.h(
                        _ForgotVerificationLayout.sectionSpacing,
                      ),
                    ),
                    if (!vm.canResend)
                      Text(
                        vm.timerText,
                        style: context.appTextStyles?.authTimerText,
                        textAlign: TextAlign.center,
                      )
                    else
                      TextButton(
                        onPressed: (vm.isResendLoading || vm.isLoading)
                            ? null
                            : () => vm.resendCode(context),
                        child: vm.isResendLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: AppLoadingIndicator.medium(
                                  color: colorScheme.primary,
                                ),
                              )
                            : Text(
                                'Resend Code',
                                style: context.appTextStyles?.authGoogleButton,
                              ),
                      ),
                    SizedBox(
                      height: context.h(_ForgotVerificationLayout.buttonTop),
                    ),
                    CustomButton(
                      onPressed: () => vm.verify(context),
                      gradient: AppColors.gradient,
                      text: 'Verify',
                      isLoading: vm.isLoading,
                    ),
                    SizedBox(height: context.h(80)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
