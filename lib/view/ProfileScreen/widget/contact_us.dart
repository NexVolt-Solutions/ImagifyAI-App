import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/custom_button.dart';
import 'package:imagifyai/Core/CustomWidget/custom_text_field.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/Core/utils/Routes/routes_name.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:imagifyai/viewModel/contact_us_view_model.dart';
import 'package:imagifyai/viewModel/profile_screen_view_model.dart';
import 'package:imagifyai/viewModel/sign_in_view_model.dart';
import 'package:provider/provider.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<ProfileScreenViewModel>().currentUser;
      context.read<ContactUsViewModel>().prepareForm(user);
    });
  }

  Future<void> _onSubmit(BuildContext context) async {
    final contactVm = context.read<ContactUsViewModel>();
    final signInVm = context.read<SignInViewModel>();
    final token = signInVm.accessToken;

    if (token == null || token.isEmpty) {
      SnackbarUtil.showTopSnackBar(
        context,
        'Please sign in to send a message.',
      );
      Navigator.pushNamed(context, RoutesName.SignInScreen);
      return;
    }

    try {
      final message = await contactVm.submitIfValid(
        formKey: _formKey,
        accessToken: token,
      );
      if (!context.mounted || message == null) return;

      final user = context.read<ProfileScreenViewModel>().currentUser;
      contactVm.prepareForm(user);

      await showDialog<void>(
        context: context,
        builder: (ctx) {
          final primaryColor = Theme.of(ctx).colorScheme.primary;
          final textColor = Theme.of(ctx).brightness == Brightness.dark
              ? Colors.white
              : Colors.black;
          final bgColor = Theme.of(ctx).scaffoldBackgroundColor;
          return AlertDialog(
            title: Text(
              'Message Sent!',
              style: TextStyle(color: textColor, fontSize: 18),
            ),
            backgroundColor: bgColor,
            content: Text(
              'We have received your message and will get back to you within '
              '24-48 hours.',
              style: TextStyle(color: textColor, height: 1.5, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('OK', style: TextStyle(color: primaryColor)),
              ),
            ],
          );
        },
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      final code = e.statusCode;
      String text;
      if (code == 429) {
        text =
            'You can only send 3 messages per hour. Please try again later.';
      } else if (code == 500) {
        text = 'Failed to send message. Please try again.';
      } else if (code == 401) {
        text = 'Your session expired. Please sign in again.';
        SnackbarUtil.showTopSnackBar(context, text);
        Navigator.pushNamed(context, RoutesName.SignInScreen);
        return;
      } else {
        text = e.message;
      }
      SnackbarUtil.showTopSnackBar(context, text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(AppAssets.starLogo, fit: BoxFit.cover),
              SvgPicture.asset(AppAssets.imagifyaiLogo, fit: BoxFit.cover),
              Positioned(
                left: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).iconTheme.color,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<ContactUsViewModel>(
        builder: (context, contactUsViewModel, _) {
          final subjects = contactUsViewModel.subjects;
          return SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                children: [
                  SizedBox(height: context.h(20)),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Contact Us',
                          style: context.appTextStyles?.profileScreenTitle,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.h(4)),
                        Text(
                          'Manage your imagifyai account settings',
                          style: context.appTextStyles?.profileScreenSubtitle,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.h(24)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            AppAssets.phoneIcon,
                            height: context.h(24),
                            width: context.w(24),
                            color: context.iconColor,
                          ),
                          SizedBox(height: context.h(11)),
                          Text(
                            '+923174869556',
                            style: context.appTextStyles?.profileContactInfo,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset(
                            AppAssets.emailIcon,
                            height: context.h(24),
                            width: context.w(24),
                            color: context.iconColor,
                          ),
                          SizedBox(height: context.h(11)),
                          Text(
                            'info@nexvoltsolutions.com',
                            style: context.appTextStyles?.profileContactInfo,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(20)),
                  CustomTextField(
                    validatorType: 'contact_name',
                    controller: contactUsViewModel.firstNameController,
                    emptyErrorMessage: 'First name is required',
                    hintText: 'Enter your first name',
                    hintStyle: context.appTextStyles?.authHintText,
                    label: 'First Name',
                    enabledBorderColor: context.colorScheme.onSurface,
                  ),
                  SizedBox(height: context.h(16)),
                  CustomTextField(
                    validatorType: 'contact_name',
                    controller: contactUsViewModel.lastNameController,
                    emptyErrorMessage: 'Last name is required',
                    hintText: 'Enter your last name',
                    hintStyle: context.appTextStyles?.authHintText,
                    label: 'Last Name',
                    enabledBorderColor: context.colorScheme.onSurface,
                  ),
                  SizedBox(height: context.h(16)),
                  CustomTextField(
                    validatorType: 'email',
                    controller: contactUsViewModel.emailController,
                    emptyErrorMessage: 'Email is required',
                    hintText: 'Enter your email',
                    hintStyle: context.appTextStyles?.authHintText,
                    label: 'Email',
                    keyboard: TextInputType.emailAddress,
                    enabledBorderColor: context.colorScheme.onSurface,
                  ),
                  SizedBox(height: context.h(20)),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Select Subject',
                      style: context.appTextStyles?.profileSectionTitle,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  SizedBox(height: context.h(20)),
                  Wrap(
                    spacing: context.w(10),
                    runSpacing: context.h(13),
                    children: List.generate(subjects.length, (index) {
                      final isSelected =
                          contactUsViewModel.selectedSubjectIndex == index;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            contactUsViewModel.setSelectedSubjectIndex(index);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.w(8),
                              vertical: context.h(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  padding: EdgeInsets.all(context.w(4)),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? context.primaryColor
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? context.primaryColor
                                          : context.colorScheme.onSurface
                                                .withValues(alpha: 0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: isSelected
                                        ? Icon(
                                            Icons.check,
                                            key: const ValueKey('check'),
                                            color:
                                                context.colorScheme.onPrimary,
                                            size: 14,
                                          )
                                        : SizedBox(
                                            key: const ValueKey('empty'),
                                            width: 14,
                                            height: 14,
                                          ),
                                  ),
                                ),
                                SizedBox(width: context.w(8)),
                                Text(
                                  subjects[index],
                                  style:
                                      (context
                                                  .appTextStyles
                                                  ?.profileContactInfo ??
                                              const TextStyle())
                                          .copyWith(
                                            color: isSelected
                                                ? context.primaryColor
                                                : context.textColor,
                                          ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: context.h(20)),
                  SizedBox(
                    width: context.w(double.infinity),
                    child: CustomTextField(
                      validatorType: 'contact_message',
                      controller: contactUsViewModel.messageController,
                      emptyErrorMessage: 'Message is required',
                      maxLength: 2000,
                      maxLines: 5,
                      hintText: 'Write your message...',
                      hintStyle: context.appTextStyles?.authHintText,
                      label: 'Message',
                      enabledBorderColor: context.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: context.h(32)),
                  CustomButton(
                    width: context.w(350),
                    text: 'Submit',
                    borderColor: null,
                    gradient: AppColors.gradient,
                    iconWidth: null,
                    iconHeight: null,
                    icon: null,
                    isLoading: contactUsViewModel.isSubmitting,
                    onPressed: contactUsViewModel.isSubmitting
                        ? null
                        : () => _onSubmit(context),
                  ),
                  SizedBox(height: context.h(20)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
