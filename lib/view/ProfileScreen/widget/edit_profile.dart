import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/align_text.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_textField.dart';
import 'package:genwalls/Core/CustomWidget/password_text.dart';
import 'package:genwalls/Core/CustomWidget/profile_image.dart';
import 'package:genwalls/Core/theme/theme_extensions.dart';
import 'package:genwalls/viewModel/edit_profile_view_model.dart';
import 'package:genwalls/viewModel/profile_screen_view_model.dart';
import 'package:genwalls/viewModel/sign_in_view_model.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool _hasLoaded = false;
  // Create formKey in widget state to ensure uniqueness per widget instance
  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoaded) return;
    _hasLoaded = true;

    final profileViewModel = context.read<ProfileScreenViewModel>();
    final editProfileViewModel = context.read<EditProfileViewModel>();
    final signInViewModel = context.read<SignInViewModel>();

    // Load user data if available
    if (profileViewModel.currentUser != null &&
        editProfileViewModel.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          editProfileViewModel.loadUserData(profileViewModel.currentUser);
        }
      });
    } else if (profileViewModel.currentUser == null &&
        !profileViewModel.isLoading) {
      // Load user data if not already loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          profileViewModel.loadCurrentUser(
            accessToken: signInViewModel.accessToken,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<EditProfileViewModel, ProfileScreenViewModel>(
      builder: (context, editProfileViewModel, profileViewModel, _) {
        // Sync user data when profileViewModel updates (only if different)
        final currentUserId = editProfileViewModel.currentUser?.id;
        final profileUserId = profileViewModel.currentUser?.id;
        if (profileViewModel.currentUser != null &&
            currentUserId != null &&
            currentUserId != profileUserId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              editProfileViewModel.loadUserData(profileViewModel.currentUser);
            }
          });
        }

        return Scaffold(
          backgroundColor: context.backgroundColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(AppAssets.starLogo, fit: BoxFit.cover),
                SvgPicture.asset(AppAssets.genWallsLogo, fit: BoxFit.cover),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).iconTheme.color,
                      ),
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
                  SizedBox(height: context.h(20)),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Edit Profile",
                      style: context.appTextStyles?.profileScreenTitle,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Manage your GENWALLS account settings",
                      style: context.appTextStyles?.profileScreenSubtitle,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  SizedBox(height: context.h(20)),
                  Container(
                    height: context.h(167),
                    width: context.w(double.infinity),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(context.radius(12)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            editProfileViewModel.profileImage != null
                                ? ClipOval(
                                    child: Image.file(
                                      editProfileViewModel.profileImage!,
                                      height: context.h(82),
                                      width: context.w(82),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : ProfileImage(
                                    imagePath:
                                        editProfileViewModel
                                            .currentUser
                                            ?.profileImageUrl ??
                                        '',
                                    height: context.h(82),
                                    width: context.w(82),
                                    fit: BoxFit.cover,
                                  ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => editProfileViewModel.pickImage(),
                                child: Container(
                                  padding: EdgeInsets.all(context.w(6)),
                                  decoration: BoxDecoration(
                                    color: context.primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: context.backgroundColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: context.textColor,
                                    size: context.text(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.h(18)),
                        Center(
                          child: Text(
                            'Click the camera icon to change your photo',
                            style: context.appTextStyles?.profileHelperText,
                          ),
                        ),
                        if (editProfileViewModel.isUpdatingPicture)
                          Padding(
                            padding: EdgeInsets.only(top: context.h(8)),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.h(20)),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: context.w(20)),
                    height: context.h(265),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(context.radius(12)),
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Persnol Information",
                            style: context.appTextStyles?.profileSectionTitle,
                            textAlign: TextAlign.start,
                          ),
                        ),
                        SizedBox(height: context.h(20)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller:
                                    editProfileViewModel.usernameController,
                                validatorType: "name",
                                label: "User name",
                                enabledBorderColor:
                                    context.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.h(16)),
                        CustomTextField(
                          controller: editProfileViewModel.emailController,
                          validatorType: "email",
                          label: "Email",
                          enabledBorderColor: context.colorScheme.onSurface,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.h(20)),
                  Container(
                    height: context.h(470),
                    width: context.w(double.infinity),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(context.radius(12)),
                    ),
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: context.h(20),
                        vertical: context.w(20),
                      ),
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Change Password",
                            style: context.appTextStyles?.profileSectionTitle,
                            textAlign: TextAlign.start,
                          ),
                        ),
                        SizedBox(height: context.h(20)),
                        CustomTextField(
                          controller:
                              editProfileViewModel.oldPasswordController,
                          validatorType: "password",
                          hintText: 'Enter old Password',
                          hintStyle: context.appTextStyles?.authHintText,
                          label: "Old Password",
                          enabledBorderColor: context.colorScheme.onSurface,
                        ),
                        SizedBox(height: context.h(16)),
                        CustomTextField(
                          controller:
                              editProfileViewModel.newPasswordController,
                          validatorType: "password",
                          hintText: 'Enter new Password',
                          hintStyle: context.appTextStyles?.authHintText,
                          label: "New Password",
                          enabledBorderColor: context.colorScheme.onSurface,
                        ),
                        SizedBox(height: context.h(16)),
                        CustomTextField(
                          controller:
                              editProfileViewModel.confirmPasswordController,
                          validatorType: "password",
                          hintText: 'Enter confirm Password',
                          hintStyle: context.appTextStyles?.authHintText,
                          label: "Confirm Password",
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
                              bool isSelected =
                                  editProfileViewModel.selectedIndex == index;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    editProfileViewModel.selectedIndex = index;
                                  });
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
                  SizedBox(height: context.h(24)),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          onPressed: editProfileViewModel.isLoading
                              ? null
                              : () {
                                  final signInViewModel = context
                                      .read<SignInViewModel>();
                                  final accessToken = signInViewModel.accessToken;
                                  if (accessToken != null &&
                                      accessToken.isNotEmpty) {
                                    editProfileViewModel.updateProfile(
                                      context: context,
                                      accessToken: accessToken,
                                      formKey: _formKey,
                                    );
                                  }
                                },
                          text: editProfileViewModel.isLoading
                              ? "Saving..."
                              : "Save Changes",
                          gradient: AppColors.gradient,
                        ),
                      ),
                      SizedBox(width: context.w(12)),
                      Expanded(
                        child: CustomButton(
                          onPressed: editProfileViewModel.isLoading
                              ? null
                              : () => Navigator.pop(context),
                          text: "Cancel",
                          icon: null,
                          borderColor: context.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  if (editProfileViewModel.isLoading)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: context.h(12)),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  SizedBox(height: context.h(50)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
