import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/CustomWidget/align_text.dart';
import 'package:genwalls/Model/viewModel/normal_text.dart';
import 'package:genwalls/Model/viewModel/up_date_align_text.dart';

class TermOfUse extends StatelessWidget {
  const TermOfUse({super.key});

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
                      text: 'Terms of use',
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                    ),
                    SizedBox(height: 10.h),

                    UpdateAlignText(
                      text: 'Last updated: [Insert Date]',
                      color: Colors.red,
                    ),
                    SizedBox(height: 10.h),

                    NormalText(
                      text:
                          'Welcome to GENWALLS (“we”, “our”, “us”). These Terms of Use govern your use of our mobile application and website (the “Service”). By accessing or using GENWALLS, you agree to be bound by these Terms.',
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 10.h),
                    AlignText(
                      text: 'Acceptance of Terms',
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                    ),
                    SizedBox(height: 10.h),
                    NormalText(
                      text:
                          'By registering or using our Service, you confirm that you are at least 13 years of age and you agree to these Terms and our Privacy Policy. If you do not agree, please discontinue use of the Service.',
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 10.h),
                    AlignText(
                      text: 'Description of Service',
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                    ),
                    SizedBox(height: 10.h),
                    NormalText(
                      text:
                          'GENWALLS is an AI-powered wallpaper generator that allows users to create unique, high-quality digital images and wallpapers using text prompts, customization features, and style options. Users can: ➤ Enter custom prompts to generate wallpapers ➤ Explore AI-suggested prompts for inspiration ➤ Select different image sizes and aspect ratios ➤ Choose from multiple artistic styles and themes ➤ Download wallpapers for personal use',
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 10.h),
                    AlignText(
                      text: 'User Accounts',
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                    ),
                    SizedBox(height: 10.h),
                    NormalText(
                      text:
                          'When creating an account, you must provide accurate and complete information. You are solely responsible for maintaining the confidentiality of your login credentials and for all activity conducted under your account.',
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 10.h),
                    AlignText(
                      text: 'Intellectual Property',
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                    ),
                    SizedBox(height: 10.h),
                    NormalText(
                      text:
                          'All content, design, branding, and AI models within GENWALLS are the exclusive property of our company. You may not copy, modify, reverse engineer, or redistribute any part of the Service without prior permission.',
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 10.h),
                    AlignText(
                      text: 'User Content',
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                    ),
                    SizedBox(height: 10.h),
                    NormalText(
                      text:
                          'Any prompts, text, or images you create remain yours. However, by generating or uploading content through GENWALLS, you grant us permission to store, process, and use anonymized data to improve the Service.You are responsible for: ➤ Ensuring your content does not violate laws or third-party rights ➤ Not generating harmful, illegal, or offensive content ➤ Avoiding false or misleading information',
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 10.h),
                    AlignText(
                      text: 'Restrictions',
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                    ),
                    SizedBox(height: 10.h),
                    NormalText(
                      text:
                          'You agree not to:  ➤ Use the Service for illegal, harmful, or abusive purposes  ➤ Attempt to hack, disrupt, or overload the Service  ➤ Sell, resell, or sublicense access to the Service  ➤ Use automated bots, scrapers, or unauthorized scripts',
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 10.h),
                    AlignText(
                      text: 'Termination',
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                    ),
                    SizedBox(height: 10.h),
                    NormalText(
                      text:
                          'We reserve the right to suspend or terminate your account if:  ➤ You violate these Terms  ➤ We suspect fraudulent or abusive behavior',
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 10.h),
                    AlignText(
                      text: 'Disclaimers',
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                    ),
                    SizedBox(height: 10.h),
                    NormalText(
                      text:
                          'GENWALLS is provided “as is” and “as available,” without warranties of any kind. Generated images are AI-created and may not always meet your expectations. We do not guarantee the accuracy, uniqueness, or quality of generated wallpapers.',
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 10.h),
                    AlignText(
                      text: 'Changes to Terms',
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                    ),
                    SizedBox(height: 10.h),
                    NormalText(
                      text:
                          'We may update these Terms of Use from time to time. You will be notified of significant changes, and continued use of GENWALLS means you accept the updated Terms.',
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 10.h),
                    AlignText(
                      text: 'Limitation of Liability',
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                    ),
                    SizedBox(height: 10.h),
                    NormalText(
                      text:
                          'We are not liable for:  ➤ Loss of data or content  ➤ Service interruptions or downtime  ➤ Any damages resulting from your use or inability to use the Service',
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 10.h),
                    AlignText(
                      text: 'Contact',
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                    ),
                    SizedBox(height: 10.h),
                    NormalText(
                      text:
                          'If you have questions about these Terms, please contact us at:  📧 support@genwalls.com  📍 [Insert office address, if any]',
                      color: Colors.white,
                      fontSize: 12.sp,
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
