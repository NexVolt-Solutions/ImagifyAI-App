import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';

class TermOfUse extends StatelessWidget {
  const TermOfUse({super.key});

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
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Terms of Use",
                style: context.appTextStyles?.profileScreenTitle,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Last updated: [Insert Date]",
                style: context.appTextStyles?.profileDateText,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Welcome to imagifyai ("we", "our", "us"). These Terms of Use govern your use of our mobile application and website (the "Service"). By accessing or using imagifyai, you agree to be bound by these Terms.',
                style: context.appTextStyles?.profileBodyText,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Acceptance of Terms",
                style: context.appTextStyles?.profileSectionTitle,
                textAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'By registering or using our Service, you confirm that you are at least 13 years of age and you agree to these Terms and our Privacy Policy. If you do not agree, please discontinue use of the Service.',
                style: context.appTextStyles?.profileBodyText,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Description of Service",
                style: context.appTextStyles?.profileSectionTitle,
                textAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'imagifyai is an AI-powered wallpaper generator that allows users to create unique, high-quality digital images and wallpapers using text prompts, customization features, and style options. Users can: ➤ Enter custom prompts to generate wallpapers ➤ Explore AI-suggested prompts for inspiration ➤ Select different image sizes and aspect ratios ➤ Choose from multiple artistic styles and themes ➤ Download wallpapers for personal use',
                style: context.appTextStyles?.profileBodyText,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "User Accounts",
                style: context.appTextStyles?.profileSectionTitle,
                textAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'When creating an account, you must provide accurate and complete information. You are solely responsible for maintaining the confidentiality of your login credentials and for all activity conducted under your account.',
                style: context.appTextStyles?.profileBodyText,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Intellectual Property",
                style: context.appTextStyles?.profileSectionTitle,
                textAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'All content, design, branding, and AI models within imagifyai are the exclusive property of our company. You may not copy, modify, reverse engineer, or redistribute any part of the Service without prior permission.',
                style: context.appTextStyles?.profileBodyText,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "User Content",
                style: context.appTextStyles?.profileSectionTitle,
                textAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Any prompts, text, or images you create remain yours. However, by generating or uploading content through imagifyai, you grant us permission to store, process, and use anonymized data to improve the Service.You are responsible for: ➤ Ensuring your content does not violate laws or third-party rights ➤ Not generating harmful, illegal, or offensive content ➤ Avoiding false or misleading information',
                style: context.appTextStyles?.profileBodyText,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Restrictions",
                style: context.appTextStyles?.profileSectionTitle,
                textAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'You agree not to: ➤ Use the Service for illegal, harmful, or abusive purposes ➤ Attempt to hack, disrupt, or overload the Service ➤ Sell, resell, or sublicense access to the Service ➤ Use automated bots, scrapers, or unauthorized scripts',
                style: context.appTextStyles?.profileBodyText,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Termination",
                style: context.appTextStyles?.profileSectionTitle,
                textAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'We reserve the right to suspend or terminate your account if: ➤ You violate these Terms ➤ We suspect fraudulent or abusive behavior',
                style: context.appTextStyles?.profileBodyText,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Disclaimers",
                style: context.appTextStyles?.profileSectionTitle,
                textAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'imagifyai is provided "as is" and "as available," without warranties of any kind. Generated images are AI-created and may not always meet your expectations. We do not guarantee the accuracy, uniqueness, or quality of generated wallpapers.',
                style: context.appTextStyles?.profileBodyText,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Changes to Terms",
                style: context.appTextStyles?.profileSectionTitle,
                textAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'We may update these Terms of Use from time to time. You will be notified of significant changes, and continued use of imagifyai means you accept the updated Terms.',
                style: context.appTextStyles?.profileBodyText,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Limitation of Liability",
                style: context.appTextStyles?.profileSectionTitle,
                textAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'We are not liable for: ➤ Loss of data or content ➤ Service interruptions or downtime ➤ Any damages resulting from your use or inability to use the Service',
                style: context.appTextStyles?.profileBodyText,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Contact",
                style: context.appTextStyles?.profileSectionTitle,
                textAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'If you have questions about these Terms, please contact us at: 📧 support@imagifyai.com 📍 [Insert office address, if any]',
                style: context.appTextStyles?.profileBodyText,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: context.h(8)),
          ],
        ),
      ),
    );
  }
}
