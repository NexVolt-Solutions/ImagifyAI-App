import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/theme/theme_extensions.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

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
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Privacy Policy",
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
                "GENWALLS values your privacy and is committed to protecting your personal information. When you use our application, we may collect certain information such as your email address, username, and account details to allow you to sign up, log in, and personalize your experience. We may also collect non-personal information including device type, operating system, language preferences, and app usage data to help us improve performance and stability. The prompts you enter to generate wallpapers and the generated wallpapers themselves may be temporarily stored for processing and service enhancement but are not shared with third parties for advertising or resale purposes. We do not sell, trade, or rent your personal data, and information may only be shared with trusted service providers that help us operate the app, or if required by law. Your data is kept only for as long as necessary to provide the service, after which it may be securely deleted, and you may also request deletion of your account and related data at any time by contacting us. We take appropriate technical and organizational measures to protect your information from unauthorized access, loss, or misuse, but you understand that no digital system can be completely secure. GENWALLS is intended for general audiences and does not knowingly collect data from children under 13 years of age; if such data is discovered it will be deleted immediately. By using the app, you consent to the collection and use of information as described in this policy. We may update this Privacy Policy from time to time, and the updated version will be available in the app. Continued use of GENWALLS after updates means you accept the revised terms. If you have any questions, concerns, or requests about your privacy, please contact us at [Your Support Email].",
                style: context.appTextStyles?.profileBodyText,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
