import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/custom_button.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/verification_view_model.dart';
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

    final args = ModalRoute.of(context)?.settings.arguments;
    String? email;
    bool autoResend = false;

    // Handle both String (email only) and Map (email + autoResend flag)
    if (args is String && args.isNotEmpty) {
      email = args;
    } else if (args is Map) {
      email = args['email']?.toString();
      autoResend = args['autoResend'] == true;
    }

    if (email != null && email.isNotEmpty) {
      final verificationViewModel = context.read<VerificationViewModel>();
      verificationViewModel.setEmail(email);

      // Auto-resend OTP if flag is set
      if (autoResend) {
        // Use a small delay to ensure the screen is fully built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          verificationViewModel.autoResendCode(context);
        });
      }
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
          textStyle: context.appTextStyles?.authOTPText,
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: BorderRadius.circular(context.radius(8)),
            border: Border.all(color: context.colorScheme.onSurface),
          ),
        );

        final emailDisplay =
            verificationViewModel.emailController.text.isNotEmpty
            ? verificationViewModel.emailController.text
            : 'your email';

        return Scaffold(
          backgroundColor: context.backgroundColor,
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
                  AppAssets.imagifyaiLogo,
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
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                children: [
                  SizedBox(height: context.h(35)),
                  Text(
                    "Verification",
                    style: context.appTextStyles?.authTitlePrimary,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.h(24)),
                  Center(
                    child: Image.asset(
                      AppAssets.verifIcon,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: context.h(24)),
                  Text(
                    "Verify Your Account",
                    style: context.appTextStyles?.authTitleWhite,
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: context.h(24)),
                  Text(
                    'Enter the 6-digit code that we have sent to $emailDisplay',
                    style: context.appTextStyles?.authBodyRegular,
                    textAlign: TextAlign.center,
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
                        style: context.appTextStyles?.authOTPLarge,
                      ),
                    ),
                  ),
                  SizedBox(height: context.h(24)),
                  if (!verificationViewModel.canResend) ...[
                    Text(
                      verificationViewModel.timerText,
                      style: context.appTextStyles?.authTimerText,
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: verificationViewModel.isLoading
                          ? null
                          : () => verificationViewModel.resendCode(context),
                      child: Text(
                        'Resend Code',
                        style: context.appTextStyles?.authResendText,
                      ),
                    ),
                  ],
                  SizedBox(height: context.h(32)),
                  CustomButton(
                    onPressed: () => verificationViewModel.verify(
                      context,
                      formKey: _formKey,
                    ),
                    gradient: AppColors.gradient,
                    text: verificationViewModel.isLoading
                        ? 'Verifying...'
                        : 'Verify Account',
                    isLoading: verificationViewModel.isLoading,
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
