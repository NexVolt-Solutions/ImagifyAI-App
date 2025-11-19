import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/CustomWidget/align_text.dart';
import 'package:genwalls/Model/viewModel/normal_text.dart';
import 'package:genwalls/Model/viewModel/up_date_align_text.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity.h,
        width: double.infinity.w,
        color: Colors.black,
        child: Stack(
          children: [
            Positioned(
              top: 30.h,
              left: 0.w,
              right: 0.w,
              child: Center(
                child: Image.asset(AppAssets.starLogo, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 30.h,
              left: 0.w,
              right: 0.w,
              child: Center(
                child: Image.asset(
                  AppAssets.genWallsLogo,
                  height: 20.h,
                  width: 120.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              top: 70.h,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AlignText(
                      text: 'Privacy Policy',
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                    ),
                    UpdateAlignText(
                      text: 'Last updated: [Insert Date]',
                      color: Colors.red,
                    ),
                    SizedBox(height: 10.h),
                    NormalText(
                      text:
                          'GENWALLS values your privacy and is committed to protecting your personal information. When you use our application, we may collect certain information such as your email address, username, and account details to allow you to sign up, log in, and personalize your experience. We may also collect non-personal information including device type, operating system, language preferences, and app usage data to help us improve performance and stability. The prompts you enter to generate wallpapers and the generated wallpapers themselves may be temporarily stored for processing and service enhancement but are not shared with third parties for advertising or resale purposes. We do not sell, trade, or rent your personal data, and information may only be shared with trusted service providers that help us operate the app, or if required by law. Your data is kept only for as long as necessary to provide the service, after which it may be securely deleted, and you may also request deletion of your account and related data at any time by contacting us. We take appropriate technical and organizational measures to protect your information from unauthorized access, loss, or misuse, but you understand that no digital system can be completely secure. GENWALLS is intended for general audiences and does not knowingly collect data from children under 13 years of age; if such data is discovered it will be deleted immediately. By using the app, you consent to the collection and use of information as described in this policy. We may update this Privacy Policy from time to time, and the updated version will be available in the app. Continued use of GENWALLS after updates means you accept the revised terms. If you have any questions, concerns, or requests about your privacy, please contact us at [Your Support Email].',
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 30.h,
              left: 20.w,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
