import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/align_text.dart';
import 'package:imagifyai/Core/CustomWidget/custom_button.dart';
import 'package:imagifyai/Core/CustomWidget/custom_textField.dart';
import 'package:imagifyai/Core/CustomWidget/password_text.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/edit_profile_view_model.dart';
import 'package:imagifyai/viewModel/profile_screen_view_model.dart';
import 'package:imagifyai/viewModel/sign_in_view_model.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoaded) return;
    _hasLoaded = true;

    final profileViewModel = context.read<ProfileScreenViewModel>();
    final editProfileViewModel = context.read<EditProfileViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && profileViewModel.currentUser != null) {
        editProfileViewModel.loadUserData(profileViewModel.currentUser);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<EditProfileViewModel, SignInViewModel>(
      builder: (context, editProfileViewModel, signInViewModel, _) {
        final accessToken = signInViewModel.accessToken;

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
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: context.h(20)),
              children: [
                SizedBox(height: context.h(16)),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Change Password',
                    style: context.appTextStyles?.profileScreenTitle,
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(height: context.h(4)),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Update your password to keep your account secure',
                    style: context.appTextStyles?.profileScreenSubtitle,
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(height: context.h(24)),
                Container(
                  width: context.w(double.infinity),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(context.radius(12)),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.h(20),
                    vertical: context.w(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: editProfileViewModel.oldPasswordController,
                        validatorType: 'password',
                        hintText: 'Enter old password',
                        hintStyle: context.appTextStyles?.authHintText,
                        label: 'Current Password',
                        enabledBorderColor: context.colorScheme.onSurface,
                      ),
                      SizedBox(height: context.h(16)),
                      CustomTextField(
                        controller: editProfileViewModel.newPasswordController,
                        validatorType: 'password',
                        hintText: 'Enter new password',
                        hintStyle: context.appTextStyles?.authHintText,
                        label: 'New Password',
                        enabledBorderColor: context.colorScheme.onSurface,
                      ),
                      SizedBox(height: context.h(16)),
                      CustomTextField(
                        controller:
                            editProfileViewModel.confirmPasswordController,
                        validatorType: 'password',
                        hintText: 'Confirm new password',
                        hintStyle: context.appTextStyles?.authHintText,
                        label: 'Confirm Password',
                        enabledBorderColor: context.colorScheme.onSurface,
                      ),
                      SizedBox(height: context.h(20)),
                      AlignText(
                        text: 'Password must contain',
                        fontWeight: FontWeight.w500,
                        fontSize: context.text(16),
                      ),
                      SizedBox(height: context.h(4)),
                      Column(
                        children: List.generate(
                          editProfileViewModel.items.length,
                          (index) {
                            final isSelected =
                                editProfileViewModel.selectedIndex == index;
                            return GestureDetector(
                              onTap: () {
                                editProfileViewModel
                                    .setSelectedPasswordRequirementIndex(index);
                              },
                              child: PasswordText(
                                text: editProfileViewModel.items[index],
                                icon: isSelected ? Icons.check : Icons.cancel,
                                iconColor: isSelected
                                    ? AppColors.greenColor
                                    : AppColors.grayColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.h(32)),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onPressed: () async {
                          if (accessToken == null || accessToken.isEmpty)
                            return;
                          final success = await editProfileViewModel
                              .updatePassword(
                                context: context,
                                accessToken: accessToken,
                              );
                          if (mounted && success) Navigator.pop(context);
                        },
                        text: 'Update',
                        isLoading: editProfileViewModel.isLoading,
                        gradient: AppColors.gradient,
                      ),
                    ),
                    SizedBox(width: context.w(12)),
                    Expanded(
                      child: CustomButton(
                        onPressed: () => Navigator.pop(context),
                        text: 'Cancel',
                        icon: null,
                        borderColor: context.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.h(40)),
              ],
            ),
          ),
        );
      },
    );
  }
}
