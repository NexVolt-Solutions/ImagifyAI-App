import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_row.dart';
import 'package:genwalls/Model/utils/Routes/routes_name.dart';
import 'package:genwalls/view/ProfileScreen/widget/contact_us.dart';
import 'package:genwalls/view/ProfileScreen/widget/privacy_policy.dart';
import 'package:genwalls/view/ProfileScreen/widget/term_of_use.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(radius: 50.r, backgroundColor: Colors.white),
                    SizedBox(height: 10.h),
                    Text(
                      'John Aley',
                      style: GoogleFonts.poppins(
                        color: Colors.purple,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5.h),

                    Text(
                      'Khan@gmail.com',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    CustomRow(
                      text1: 'Theme',
                      text2: 'Light Dark',
                      iconImag1: AppAssets.themeIcon,
                      showSwitch: true,
                      rightIcon: false,
                    ),
                    SizedBox(height: 10.h),
                    CustomRow(
                      text1: 'Notifcation',
                      text2: 'Push Notifcation enabled',
                      iconImag1: AppAssets.shieldIcon,
                      showSwitch: true,
                      rightIcon: false,
                    ),
                    SizedBox(height: 10.h),
                    CustomRow(
                      OnPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicy(),
                          ),
                        );
                      },
                      text1: 'Privacy Policy',
                      text2: 'Read how we collect and protect your data',
                      iconImag1: AppAssets.bellIcon,
                      showSwitch: false,
                      rightIcon: true,
                    ),
                    SizedBox(height: 10.h),
                    CustomRow(
                      OnPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TermOfUse()),
                        );
                      },
                      text1: 'Terms of Service',
                      text2: 'Read our terms of services',
                      iconImag1: AppAssets.termIcon,
                      showSwitch: false,
                      rightIcon: true,
                    ),
                    SizedBox(height: 10.h),
                    CustomRow(
                      OnPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactUs(),
                          ),
                        );
                      },
                      text1: 'Contact Us',
                      text2: 'Contact us from your phone',
                      iconImag1: AppAssets.contactIcon,
                      showSwitch: false,
                      rightIcon: true,
                    ),
                    SizedBox(height: 20.h),
                    Center(
                      child: CustomButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            RoutesName.BottomNavScreen,
                          );
                        },
                        height: 48.h,
                        width: 350.w,
                        text: 'Sign Out',
                        icon: null,
                      ),
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
