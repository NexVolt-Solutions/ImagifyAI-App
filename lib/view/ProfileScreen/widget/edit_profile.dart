import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/align_text.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_textField.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';
import 'package:genwalls/Core/CustomWidget/password_text.dart';
import 'package:genwalls/viewModel/edit_profile_view_model.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final editProfileViewModel = EditProfileViewModel();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(AppAssets.starLogo, fit: BoxFit.cover),
            Image.asset(AppAssets.genWallsLogo, fit: BoxFit.cover),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.whiteColor,
                  ),
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
            SizedBox(height: context.h(20)),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText: "Edit Profile",
                titleSize: context.text(20),
                titleWeight: FontWeight.w600,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                subText: "Manage your GENWALLS account settings",
                subSize: context.text(14),
                subColor: AppColors.textFieldSubTitleColor,
                subWeight: FontWeight.w500,
                subAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(20)),
            Container(
              height: context.h(167),
              width: context.w(double.infinity),
              decoration: BoxDecoration(
                color: AppColors.containerColor,
                borderRadius: BorderRadius.circular(context.radius(12)),
              ),
              child: ListView(
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  SizedBox(height: context.h(32)),
                  Container(
                    height: context.h(82),
                    width: context.w(82),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.subTitleColor,
                    ),
                    child: Image.asset(
                      AppAssets.profileIcon,
                      height: context.h(38),
                      width: context.w(38),
                      color: AppColors.whiteColor,
                    ),
                  ),
                  SizedBox(height: context.h(18)),
                  Center(
                    child: Text(
                      'Click the camera icon to change your photo',
                      style: GoogleFonts.poppins(
                        color: AppColors.whiteColor,
                        fontSize: context.text(12),
                        fontWeight: FontWeight.w500,
                      ),
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
                color: AppColors.containerColor,
                borderRadius: BorderRadius.circular(context.radius(12)),
              ),
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: NormalText(
                      titleText: "Persnol Information",
                      titleSize: context.text(16),
                      titleWeight: FontWeight.w600,
                      titleColor: AppColors.whiteColor,
                      titleAlign: TextAlign.start,
                    ),
                  ),
                  SizedBox(height: context.h(20)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          validatorType: "name",
                          label: "First name",
                          enabledBorderColor: AppColors.textFieldIconColor,
                        ),
                      ),
                      SizedBox(width: context.w(12)),
                      Expanded(
                        child: CustomTextField(
                          validatorType: "name",
                          label: "Last Name",
                          enabledBorderColor: AppColors.textFieldIconColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(16)),
                  CustomTextField(
                    validatorType: "email",
                    label: "Email",
                    enabledBorderColor: AppColors.textFieldIconColor,
                  ),
                  SizedBox(height: context.h(20)),
                ],
              ),
            ),
            SizedBox(height: context.h(20)),
            Container(
              height: context.h(470),
              width: context.w(double.infinity),
              decoration: BoxDecoration(
                color: AppColors.containerColor,
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
                    child: NormalText(
                      titleText: "Change Password",
                      titleSize: context.text(16),
                      titleWeight: FontWeight.w600,
                      titleColor: AppColors.whiteColor,
                      titleAlign: TextAlign.start,
                    ),
                  ),
                  SizedBox(height: context.h(20)),
                  CustomTextField(
                    validatorType: "password",
                    hintText: 'Enter old Password',
                    hintStyle: TextStyle(
                      color: AppColors.textFieldSubTitleColor,
                      fontWeight: FontWeight.w500,
                      fontSize: context.text(12),
                    ),
                    label: "Old Password",
                    enabledBorderColor: AppColors.textFieldIconColor,
                  ),
                  SizedBox(height: context.h(16)),
                  CustomTextField(
                    validatorType: "password",
                    hintText: 'Enter new Password',
                    hintStyle: TextStyle(
                      color: AppColors.textFieldSubTitleColor,
                      fontWeight: FontWeight.w500,
                      fontSize: context.text(12),
                    ),
                    label: "New Password",
                    enabledBorderColor: AppColors.textFieldIconColor,
                  ),
                  SizedBox(height: context.h(16)),
                  CustomTextField(
                    validatorType: "password",
                    hintText: 'Enter confirm Password',
                    hintStyle: TextStyle(
                      color: AppColors.textFieldSubTitleColor,
                      fontWeight: FontWeight.w500,
                      fontSize: context.text(12),
                    ),
                    label: "Confirm Password",
                    enabledBorderColor: AppColors.textFieldIconColor,
                  ),
                  SizedBox(height: context.h(20)),
                  AlignText(
                    text: 'Password must contain',
                    fontWeight: FontWeight.w500,
                    fontSize: context.text(16),
                  ),
                  SizedBox(height: context.h(4)),
                  Column(
                    children: List.generate(editProfileViewModel.items.length, (
                      index,
                    ) {
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
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.h(96)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  height: context.h(48),
                  width: context.w(165),
                  text: "Save Changes",
                  icon: null,
                  borderColor: null,
                  gradient: AppColors.gradient,
                  iconWidth: null,
                  iconHeight: null,
                ),
                CustomButton(
                  height: context.h(48),
                  width: context.w(165),
                  text: "Cancel",
                  icon: null,
                  borderColor: AppColors.whiteColor,
                  gradient: null,

                  iconWidth: null,
                  iconHeight: null,
                ),
              ],
            ),
            SizedBox(height: context.h(50)),
          ],
        ),
      ),
    );
  }
}
