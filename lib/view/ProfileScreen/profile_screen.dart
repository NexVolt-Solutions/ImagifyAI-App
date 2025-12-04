import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';
import 'package:genwalls/Core/CustomWidget/profile_image.dart';
import 'package:genwalls/viewModel/profile_screen_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final profileScreenViewModel = ProfileScreenViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              child: Image.asset(AppAssets.starLogo, fit: BoxFit.cover),
            ),
            Image.asset(AppAssets.genWallsLogo, fit: BoxFit.cover),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: context.h(20)),
          children: [
            SizedBox(height: context.h(20)),
            Center(
              child: ProfileImage(
                imagePath: AppAssets.conIcon,
                height: context.h(100),
                width: context.h(100),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: context.h(12)),
            NormalText(
              titleText: "M.Shehzad",
              titleSize: context.text(16),
              titleWeight: FontWeight.w500,
              titleColor: AppColors.primeryColor,
              titleAlign: TextAlign.center,
              subText: "Khan@gmail.com",
              subSize: context.text(12),
              subColor: AppColors.whiteColor,
              subWeight: FontWeight.w500,
              subAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(20)),
            ListView.builder(
              itemCount: profileScreenViewModel.profileData.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = profileScreenViewModel.profileData[index];
                return ListTile(
                  onTap: () => profileScreenViewModel.onTapFun(context, index),
                  contentPadding: EdgeInsets.zero,
                  leading: item['leading'] != null
                      ? Image.asset(
                          item['leading'],
                          height: 26,
                          width: 26,
                          fit: BoxFit.contain,
                        )
                      : const SizedBox.shrink(),
                  title: Text(
                    item['title'] ?? '',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: context.text(14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    item['subtitle'] ?? '',
                    style: TextStyle(
                      color: AppColors.subTitleColor,
                      fontSize: context.text(13),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  trailing: item['trailingType'] == 'switch'
                      ? Switch(
                          inactiveThumbColor: AppColors.textFieldIconColor,
                          activeTrackColor: AppColors.whiteColor,
                          activeThumbColor: AppColors.primeryColor,
                          value: item['switchValue'] ?? false,
                          onChanged: (val) {
                            setState(() {
                              item['switchValue'] = val;
                            });
                          },
                          activeColor: Colors.white,
                        )
                      : const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                );
              },
            ),
            SizedBox(height: context.h(20)),
            CustomButton(
              onPressed: () {
                // Navigator.pushNamed(
                //   context,
                //   RoutesName.,
                // );
              },
              height: context.h(48),
              width: context.w(350),
              text: 'Sign out',
              iconWidth: null,
              iconHeight: null,
              icon: null,
            ),
          ],
        ),
      ),
    );
  }
}
