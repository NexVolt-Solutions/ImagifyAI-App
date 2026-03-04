import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';
import 'package:imagifyai/Core/CustomWidget/custom_button.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/verification_view_model.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

/// Standard layout and OTP pin sizing for the verification screen.
class _VerificationLayout {
  _VerificationLayout._();

  static const double screenPaddingH = 24;
  static const double sectionSpacing = 24;
  static const double titleTop = 32;
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

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  bool _initialized = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final vm = context.read<VerificationViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      vm.onScreenEnter(context);
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<VerificationViewModel>(
      builder: (context, vm, _) {
        // Grey for empty/default fields
        final greyBorderColor = colorScheme.onSurface.withOpacity(0.42);
        // Primary only when user is interacting (focused field)
        final focusedBorderColor = colorScheme.primary;
        // White for fields that already have a digit (1, 2, etc.)
        final filledBorderColor = Colors.white;
        // Red for error state (invalid or failed verification)
        final errorBorderColor = colorScheme.error;

        final basePinTheme = PinTheme(
          width: _VerificationLayout.pinSize,
          height: _VerificationLayout.pinSize,
          textStyle: context.appTextStyles?.authOTPText,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(_VerificationLayout.pinRadius),
            border: Border.all(
              color: greyBorderColor,
              width: _VerificationLayout.pinBorderWidth,
            ),
          ),
        );

        final defaultPinTheme = basePinTheme;
        final focusedPinTheme = basePinTheme.copyWith(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(_VerificationLayout.pinRadius),
            border: Border.all(
              color: focusedBorderColor,
              width: _VerificationLayout.pinBorderWidthFocused,
            ),
          ),
        );
        final filledPinTheme = basePinTheme.copyWith(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(_VerificationLayout.pinRadius),
            border: Border.all(
              color: filledBorderColor,
              width: _VerificationLayout.pinBorderWidth,
            ),
          ),
        );
        final errorPinTheme = basePinTheme.copyWith(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(_VerificationLayout.pinRadius),
            border: Border.all(
              color: errorBorderColor,
              width: _VerificationLayout.pinBorderWidthFocused,
            ),
          ),
        );

        final hasError = vm.errorMessage != null;
        final effectiveDefault = hasError ? errorPinTheme : defaultPinTheme;
        final effectiveFocused = hasError ? errorPinTheme : focusedPinTheme;
        final effectiveFilled = hasError ? errorPinTheme : filledPinTheme;

        final emailDisplay = vm.emailController.text.isNotEmpty
            ? vm.emailController.text
            : 'your email';

        return Scaffold(
          backgroundColor: context.backgroundColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(
              _VerificationLayout.appBarHeight,
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
                        size: _VerificationLayout.backIconSize,
                      ),
                      padding: const EdgeInsets.all(
                        _VerificationLayout.backPadding,
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
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(child: Image.asset(AppAssets.forgotIcon)),
                      SizedBox(
                        height: context.h(_VerificationLayout.sectionSpacing),
                      ),
                      Text(
                        'Verify Your Account',
                        style: context.appTextStyles?.authTitleWhite,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: context.h(_VerificationLayout.sectionSpacing),
                      ),
                      Text(
                        'Enter the 6-digit code that we have sent to $emailDisplay',
                        style: context.appTextStyles?.authBodyRegular,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: context.h(_VerificationLayout.sectionSpacing),
                      ),
                      Pinput(
                        length: 6,
                        controller: vm.codeController,
                        defaultPinTheme: effectiveDefault,
                        focusedPinTheme: effectiveFocused,
                        submittedPinTheme: effectiveFilled,
                        followingPinTheme: effectiveDefault,
                        separatorBuilder: (_) => SizedBox(
                          width: context.w(_VerificationLayout.pinSpacing),
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
                        height: context.h(_VerificationLayout.sectionSpacing),
                      ),
                      // Resend only when OTP expired / user wants new code (separate flow from verify)
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
                                  style:
                                      context.appTextStyles?.authGoogleButton,
                                ),
                        ),
                      SizedBox(
                        height: context.h(_VerificationLayout.buttonTop),
                      ),
                      CustomButton(
                        onPressed: () => vm.verify(context, formKey: _formKey),
                        gradient: AppColors.gradient,
                        text: 'Verify Account',
                        isLoading: vm.isLoading,
                      ),
                      SizedBox(height: context.h(80)),
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
