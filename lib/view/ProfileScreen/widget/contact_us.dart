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
         //with arrow 
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(65),

            child: Align(
              alignment: Alignment.bottomCenter,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(AppAssets.starLogo, fit: BoxFit.cover),
                  SvgPicture.asset(AppAssets.genWallsLogo, fit: BoxFit.cover),
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
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
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
                                    : context.colorScheme.onSurface.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      key: const ValueKey('check'),
                                      color: context.colorScheme.onPrimary,
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
                            style: (context.appTextStyles?.profileContactInfo ?? TextStyle()).copyWith(
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
