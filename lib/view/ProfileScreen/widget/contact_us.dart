import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_textField.dart';
import 'package:genwalls/Core/theme/theme_extensions.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  int selectedIndex = 0;

  final List<String> subjects = [
    "Feature Request",
    "General Feedback",
    "Bug Report",
    "Issue with Wallpaper Generation",
  ];
  @override
  Widget build(BuildContext context) {
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
                    "Contact Us",
                    style: context.appTextStyles?.profileScreenTitle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.h(4)),
                  Text(
                    "Manage your GENWALLS account settings",
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
                    ),
                    SizedBox(height: context.h(11)),
                    Text(
                      '+1012 3456 789',
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
                    ),
                    SizedBox(height: context.h(11)),
                    Text(
                      'demo@gmail.com',
                      style: context.appTextStyles?.profileContactInfo,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: context.h(20)),
            CustomTextField(
              validatorType: "name",
              hintText: 'Enter your first name',
              hintStyle: context.appTextStyles?.authHintText,
              label: "First Name",
              enabledBorderColor: context.colorScheme.onSurface,
            ),
            SizedBox(height: context.h(16)),
            CustomTextField(
              validatorType: "name",
              hintText: 'Enter your last name',
              hintStyle: context.appTextStyles?.authHintText,
              label: "Last Name",
              enabledBorderColor: context.colorScheme.onSurface,
            ),
            SizedBox(height: context.h(16)),
            CustomTextField(
              validatorType: "email",
              hintText: 'Enter your email name',
              hintStyle: context.appTextStyles?.authHintText,
              label: "Email",
              enabledBorderColor: context.colorScheme.onSurface,
            ),
            SizedBox(height: context.h(20)),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Select Subject",
                style: context.appTextStyles?.profileScreenTitle,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(20)),
            Wrap(
              spacing: context.w(10),
              runSpacing: context.h(13),
              children: List.generate(subjects.length, (index) {
                bool isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: context.radius(10),
                        backgroundColor: isSelected
                            ? context.primaryColor
                            : context.subtitleColor,
                        child: isSelected
                            ? Icon(Icons.check, color: context.textColor, size: 12)
                            : null,
                      ),
                      SizedBox(width: context.w(3.5)),
                      Text(
                        subjects[index],
                        style: context.appTextStyles?.profileContactInfo,
                      ),
                    ],
                  ),
                );
              }),
            ),
            SizedBox(height: context.h(20)),
            CustomTextField(
              validatorType: "name",
              hintText: 'Write your message...',
              hintStyle: context.appTextStyles?.authHintText,
              label: "Message",
              enabledBorderColor: context.colorScheme.onSurface,
            ),
            SizedBox(height: context.h(100)),
            CustomButton(
               
              width: context.w(350),
              text: "Save Changes",
              borderColor: null,
              gradient: AppColors.gradient,
              iconWidth: null,
              iconHeight: null,
              icon: null,
            ),
            SizedBox(height: context.h(20)),
          ],
        ),
      ),
    );
  }
}
