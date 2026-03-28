import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';
import 'package:imagifyai/Core/CustomWidget/custom_button.dart';
import 'package:imagifyai/Core/CustomWidget/custom_text_field.dart';
import 'package:imagifyai/Core/CustomWidget/custom_text_rich.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/sign_in_view_model.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // Create formKey in widget state to ensure uniqueness per widget instance
  final _formKey = GlobalKey<FormState>();
  bool _didClearFormOnEnter = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didClearFormOnEnter) {
      _didClearFormOnEnter = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<SignInViewModel>().clearForm();
        _formKey.currentState?.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignInViewModel>(
      builder: (context, signInViewModel, _) {
        return Scaffold(
          backgroundColor: context.backgroundColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(65),
            child: Container(
              color: context.backgroundColor,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(AppAssets.starLogo, fit: BoxFit.cover),
                    SvgPicture.asset(
                      AppAssets.imagifyaiLogo,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.h(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                SizedBox(height: context.h(20)),
                                Text(
                                  "Sign In",
                                  style:
                                      context.appTextStyles?.authTitlePrimary,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: context.h(16)),
                                CustomTextField(
                                  controller: signInViewModel.emailController,
                                  prefixIcon: Icon(Icons.email),
                                  validatorType: "email",
                                  hintText: 'Enter your email',
                                  hintStyle:
                                      context.appTextStyles?.authHintText,
                                  label: "Email",
                                  emptyErrorMessage: "Email is required",
                                  enabledBorderColor:
                                      context.colorScheme.onSurface,
                                ),
                                SizedBox(height: context.h(16)),
                                CustomTextField(
                                  controller:
                                      signInViewModel.passwordController,
                                  prefixIcon: Icon(Icons.lock),
                                  validatorType: "password",
                                  hintText: 'Enter your password',
                                  hintStyle:
                                      context.appTextStyles?.authHintText,
                                  label: "Password",
                                  emptyErrorMessage: "Password is required",
                                  enabledBorderColor:
                                      context.colorScheme.onSurface,
                                ),
                                SizedBox(height: context.h(8)),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Checkbox(
                                          visualDensity: VisualDensity.compact,
                                          activeColor: AppColors.greenColor,
                                          value: signInViewModel.rememberMe,
                                          side: BorderSide(
                                            color:
                                                context.colorScheme.onSurface,
                                          ),
                                          onChanged:
                                              signInViewModel.toggleRemember,
                                        ),
                                        Text(
                                          'Remember me',
                                          style: context
                                              .appTextStyles
                                              ?.authBodyMedium,
                                        ),
                                      ],
                                    ),
                                    CustomTextRich(
                                      text2: 'Forgot Password?',
                                      textSize2: context.text(14),
                                      onTap2: () =>
                                          signInViewModel.navigateToForgotPassword(
                                              context),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                CustomButton(
                                  onPressed: signInViewModel.isGoogleLoading
                                      ? null
                                      : () => signInViewModel.login(
                                          context,
                                          formKey: _formKey,
                                        ),
                                  width: context.w(350),
                                  gradient: AppColors.gradient,
                                  text: 'Sign In',
                                  isLoading: signInViewModel.isLoading,
                                  iconWidth: null,
                                  iconHeight: null,
                                  icon: null,
                                ),
                                SizedBox(height: context.h(20)),
                                GestureDetector(
                                  onTap:
                                      (signInViewModel.isLoading ||
                                          signInViewModel.isGoogleLoading)
                                      ? null
                                      : () => signInViewModel.signInWithGoogle(
                                          context,
                                        ),
                                  child: Opacity(
                                    opacity: signInViewModel.isGoogleLoading
                                        ? 0.7
                                        : 1.0,
                                    child: Container(
                                      height: context.h(47.9),
                                      width: context.w(350),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: context.colorScheme.onSurface,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          context.radius(8),
                                        ),
                                      ),
                                      child: signInViewModel.isGoogleLoading
                                          ? const Center(
                                              child:
                                                  AppLoadingIndicator.medium(),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  AppAssets.googleIcon,
                                                  height: context.h(23.94),
                                                  width: context.w(23.94),
                                                ),
                                                SizedBox(width: context.w(8)),
                                                Text(
                                                  'Continue with Google',
                                                  style: context
                                                      .appTextStyles
                                                      ?.authGoogleButton,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: context.h(20)),
                                CustomTextRich(
                                  text1: 'Don\'t have an account? ',
                                  text2: 'SignUp',
                                  textSize1: context.text(14),
                                  textSize2: context.text(14),
                                  onTap2: () =>
                                      signInViewModel.navigateToSignUp(context),
                                ),
                                SizedBox(height: context.h(20)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
