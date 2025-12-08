import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';

class TermOfUse extends StatelessWidget {
  const TermOfUse({super.key});

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
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText: "Privacy Policy",
                titleSize: context.text(20),
                titleWeight: FontWeight.w600,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                subText: "Last updated: [Insert Date]",
                subSize: context.text(10),
                subColor: AppColors.errorColor,
                subWeight: FontWeight.w400,
                subAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText:
                    'Welcome to GENWALLS (“we”, “our”, “us”). These Terms of Use govern your use of our mobile application and website (the “Service”). By accessing or using GENWALLS, you agree to be bound by these Terms.',
                titleSize: context.text(12),
                titleWeight: FontWeight.w500,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText: "Acceptance of Terms",
                titleSize: context.text(20),
                titleWeight: FontWeight.w600,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText:
                    'By registering or using our Service, you confirm that you are at least 13 years of age and you agree to these Terms and our Privacy Policy. If you do not agree, please discontinue use of the Service.',
                titleSize: context.text(12),
                titleWeight: FontWeight.w500,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText: "Description of Service",
                titleSize: context.text(20),
                titleWeight: FontWeight.w600,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText:
                    'GENWALLS is an AI-powered wallpaper generator that allows users to create unique, high-quality digital images and wallpapers using text prompts, customization features, and style options. Users can: ➤ Enter custom prompts to generate wallpapers ➤ Explore AI-suggested prompts for inspiration ➤ Select different image sizes and aspect ratios ➤ Choose from multiple artistic styles and themes ➤ Download wallpapers for personal use',
                titleSize: context.text(12),
                titleWeight: FontWeight.w500,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText: "User Accounts",
                titleSize: context.text(20),
                titleWeight: FontWeight.w600,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText:
                    'When creating an account, you must provide accurate and complete information. You are solely responsible for maintaining the confidentiality of your login credentials and for all activity conducted under your account.',
                titleSize: context.text(12),
                titleWeight: FontWeight.w500,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText: "Intellectual Property",
                titleSize: context.text(20),
                titleWeight: FontWeight.w600,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText:
                    'All content, design, branding, and AI models within GENWALLS are the exclusive property of our company. You may not copy, modify, reverse engineer, or redistribute any part of the Service without prior permission.',
                titleSize: context.text(12),
                titleWeight: FontWeight.w500,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText: "User Content",
                titleSize: context.text(20),
                titleWeight: FontWeight.w600,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText:
                    'Any prompts, text, or images you create remain yours. However, by generating or uploading content through GENWALLS, you grant us permission to store, process, and use anonymized data to improve the Service.You are responsible for: ➤ Ensuring your content does not violate laws or third-party rights ➤ Not generating harmful, illegal, or offensive content ➤ Avoiding false or misleading information',
                titleSize: context.text(12),
                titleWeight: FontWeight.w500,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText: "Restrictions",
                titleSize: context.text(20),
                titleWeight: FontWeight.w600,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText:
                    'You agree not to: ➤ Use the Service for illegal, harmful, or abusive purposes ➤ Attempt to hack, disrupt, or overload the Service ➤ Sell, resell, or sublicense access to the Service ➤ Use automated bots, scrapers, or unauthorized scripts',
                titleSize: context.text(12),
                titleWeight: FontWeight.w500,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText: "Termination",
                titleSize: context.text(20),
                titleWeight: FontWeight.w600,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText:
                    'We reserve the right to suspend or terminate your account if: ➤ You violate these Terms ➤ We suspect fraudulent or abusive behavior',
                titleSize: context.text(12),
                titleWeight: FontWeight.w500,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText: "Disclaimers",
                titleSize: context.text(20),
                titleWeight: FontWeight.w600,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText:
                    'GENWALLS is provided “as is” and “as available,” without warranties of any kind. Generated images are AI-created and may not always meet your expectations. We do not guarantee the accuracy, uniqueness, or quality of generated wallpapers.',
                titleSize: context.text(12),
                titleWeight: FontWeight.w500,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText: "Changes to Terms",
                titleSize: context.text(20),
                titleWeight: FontWeight.w600,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText:
                    'We may update these Terms of Use from time to time. You will be notified of significant changes, and continued use of GENWALLS means you accept the updated Terms.',
                titleSize: context.text(12),
                titleWeight: FontWeight.w500,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText: "Limitation of Liability",
                titleSize: context.text(20),
                titleWeight: FontWeight.w600,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText:
                    'We are not liable for: ➤ Loss of data or content ➤ Service interruptions or downtime ➤ Any damages resulting from your use or inability to use the Service',
                titleSize: context.text(12),
                titleWeight: FontWeight.w500,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText: "Contact",
                titleSize: context.text(20),
                titleWeight: FontWeight.w600,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                titleText:
                    'If you have questions about these Terms, please contact us at: 📧 support@genwalls.com 📍 [Insert office address, if any]',
                titleSize: context.text(12),
                titleWeight: FontWeight.w500,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
          ],
        ),
      ),
    );
  }
}
