import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_textField.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';
import 'package:google_fonts/google_fonts.dart';

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
              alignment: Alignment.center,
              child: NormalText(
                crossAxisAlignment: CrossAxisAlignment.center,
                titleText: "Contact Us",
                titleSize: context.text(20),
                titleWeight: FontWeight.w600,
                titleColor: AppColors.whiteColor,
                subText: "Manage your GENWALLS account settings",
                subSize: context.text(14),
                subColor: AppColors.textFieldSubTitleColor,
                subWeight: FontWeight.w500,
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
                      style: GoogleFonts.poppins(
                        color: AppColors.whiteColor,
                        fontSize: context.text(12),
                        fontWeight: FontWeight.w500,
                      ),
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
                      style: GoogleFonts.poppins(
                        color: AppColors.whiteColor,
                        fontSize: context.text(12),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: context.h(20)),
            CustomTextField(
              validatorType: "name",
              hintText: 'Enter your first name',
              hintStyle: TextStyle(
                color: AppColors.textFieldSubTitleColor,
                fontWeight: FontWeight.w500,
                fontSize: context.text(12),
              ),
              label: "First Name",
              enabledBorderColor: AppColors.textFieldIconColor,
            ),
            SizedBox(height: context.h(16)),
            CustomTextField(
              validatorType: "name",
              hintText: 'Enter your last name',
              hintStyle: TextStyle(
                color: AppColors.textFieldSubTitleColor,
                fontWeight: FontWeight.w500,
                fontSize: context.text(12),
              ),
              label: "Last Name",
              enabledBorderColor: AppColors.textFieldIconColor,
            ),
            SizedBox(height: context.h(16)),
            CustomTextField(
              validatorType: "email",
              hintText: 'Enter your email name',
              hintStyle: TextStyle(
                color: AppColors.textFieldSubTitleColor,
                fontWeight: FontWeight.w500,
                fontSize: context.text(12),
              ),
              label: "Email",
              enabledBorderColor: AppColors.textFieldIconColor,
            ),
            SizedBox(height: context.h(20)),
            Align(
              alignment: Alignment.topLeft,
              child: NormalText(
                crossAxisAlignment: CrossAxisAlignment.start,
                titleText: "Select Subject",
                titleSize: context.text(20),
                titleWeight: FontWeight.w600,
                titleColor: AppColors.whiteColor,
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
                        radius: 10.r,
                        backgroundColor: isSelected
                            ? const Color(0xFF9B4DFF)
                            : Colors.grey,
                        child: isSelected
                            ? Icon(Icons.check, color: Colors.white, size: 12.r)
                            : null,
                      ),
                      SizedBox(width: context.w(3.5)),
                      Text(
                        subjects[index],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: context.text(12),
                          fontWeight: FontWeight.w500,
                        ),
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
              hintStyle: TextStyle(
                color: AppColors.textFieldSubTitleColor,
                fontWeight: FontWeight.w500,
                fontSize: context.text(12),
              ),
              label: "Message",
              enabledBorderColor: AppColors.textFieldIconColor,
            ),
            SizedBox(height: context.h(100)),
            CustomButton(
              height: context.h(48),
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

    // Scaffold(
    //   body: Container(
    //     height: double.infinity.h,
    //     width: double.infinity.w,
    //     color: Colors.black,
    //     child: Stack(
    //       children: [
    //         Positioned(
    //           top: 30.h,
    //           left: 0.w,
    //           right: 0.w,
    //           child: Center(
    //             child: Image.asset(AppAssets.starLogo, fit: BoxFit.cover),
    //           ),
    //         ),
    //         Positioned(
    //           top: 30.h,
    //           left: 0.w,
    //           right: 0.w,
    //           child: Center(
    //             child: Image.asset(
    //               AppAssets.genWallsLogo,
    //               height: 20.h,
    //               width: 120.w,
    //               fit: BoxFit.cover,
    //             ),
    //           ),
    //         ),
    //         Positioned.fill(
    //           top: 70.h,
    //           child: SingleChildScrollView(
    //             child: Column(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 SizedBox(height: 10.h),
    //                 Text(
    //                   'Contact Us',
    //                   style: GoogleFonts.poppins(
    //                     color: Colors.white,
    //                     fontSize: 20.sp,
    //                     fontWeight: FontWeight.w600,
    //                   ),
    //                   textAlign: TextAlign.center,
    //                 ),
    //                 SizedBox(height: 5.h),
    //                 Text(
    //                   'Any question or remarks? Just write us a message!',
    //                   style: GoogleFonts.poppins(
    //                     color: Colors.white,
    //                     fontSize: 14.sp,
    //                     fontWeight: FontWeight.w500,
    //                   ),
    //                   textAlign: TextAlign.center,
    //                 ),
    //                 SizedBox(height: 10.h),
    //                 Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                   children: [
    //                     Column(
    //                       children: [
    //                         Image.asset(
    //                           AppAssets.phoneIcon,
    //                           height: 30.h,
    //                           width: 30.w,
    //                         ),
    //                         Text(
    //                           '+1012 3456 789',
    //                           style: GoogleFonts.poppins(
    //                             color: Colors.white,
    //                             fontSize: 12.sp,
    //                             fontWeight: FontWeight.w500,
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                     Column(
    //                       children: [
    //                         Image.asset(
    //                           AppAssets.emailIcon,
    //                           height: 30.h,
    //                           width: 30.w,
    //                         ),
    //                         Text(
    //                           'demo@gmail.com',
    //                           style: GoogleFonts.poppins(
    //                             color: Colors.white,
    //                             fontSize: 12.sp,
    //                             fontWeight: FontWeight.w500,
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ],
    //                 ),
    //                 SizedBox(height: 10.h),
    //                 Column(
    //                   children: [
    //                     AlignText(
    //                       text: 'First Name',
    //                       fontWeight: FontWeight.w500,
    //                       fontSize: 16.sp,
    //                     ),
    //                     SimpleTextField(
    //                       hintText: 'Ahmad',
    //                       controller: TextEditingController(),
    //                       validatorType: "name",
    //                     ),
    //                   ],
    //                 ),
    //                 SizedBox(height: 10.h),
    //                 Column(
    //                   children: [
    //                     AlignText(
    //                       text: 'Last Name',
    //                       fontWeight: FontWeight.w500,
    //                       fontSize: 16.sp,
    //                     ),
    //                     SimpleTextField(
    //                       hintText: 'Khan',
    //                       controller: TextEditingController(),
    //                       validatorType: "name",
    //                     ),
    //                   ],
    //                 ),
    //                 SizedBox(height: 10.h),
    //                 Column(
    //                   children: [
    //                     AlignText(
    //                       text: 'Phone Number',
    //                       fontWeight: FontWeight.w500,
    //                       fontSize: 16.sp,
    //                     ),
    //                     SimpleTextField(
    //                       hintText: '0316XXXXXXX',
    //                       controller: TextEditingController(),
    //                       validatorType: "phone",
    //                     ),
    //                   ],
    //                 ),
    //                 SizedBox(height: 10.h),
    //                 Column(
    //                   children: [
    //                     AlignText(
    //                       text: 'Email',
    //                       fontWeight: FontWeight.w500,
    //                       fontSize: 16.sp,
    //                     ),
    //                     SimpleTextField(
    //                       hintText: 'Khan@gmail.com',
    //                       controller: TextEditingController(),
    //                       validatorType: "email",
    //                     ),
    //                   ],
    //                 ),
    //                 SizedBox(height: 10.h),
    //                 Padding(
    //                   padding: EdgeInsets.symmetric(horizontal: 20.w),
    //                   child: Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: [
    //                       Text(
    //                         "Select Subject?",
    //                         style: GoogleFonts.poppins(
    //                           color: Colors.white,
    //                           fontSize: 16.sp,
    //                           fontWeight: FontWeight.w600,
    //                         ),
    //                       ),
    //                       SizedBox(height: 16.h),

    //                       Wrap(
    //                         spacing: 30.w,
    //                         runSpacing: 20.h,
    //                         children: List.generate(subjects.length, (index) {
    //                           bool isSelected = selectedIndex == index;

    //                           return GestureDetector(
    //                             onTap: () {
    //                               setState(() {
    //                                 selectedIndex = index;
    //                               });
    //                             },
    //                             child: Row(
    //                               mainAxisSize: MainAxisSize.min,
    //                               children: [
    //                                 CircleAvatar(
    //                                   radius: 10.r,
    //                                   backgroundColor: isSelected
    //                                       ? const Color(0xFF9B4DFF)
    //                                       : Colors.grey,
    //                                   child: isSelected
    //                                       ? Icon(
    //                                           Icons.check,
    //                                           color: Colors.white,
    //                                           size: 12.r,
    //                                         )
    //                                       : null,
    //                                 ),
    //                                 SizedBox(width: 8.w),
    //                                 Text(
    //                                   subjects[index],
    //                                   style: GoogleFonts.poppins(
    //                                     color: Colors.white,
    //                                     fontSize: 12.sp,
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                           );
    //                         }),
    //                       ),
    //                     ],
    //                   ),
    //                 ),

    //                 SizedBox(height: 10.h),
    //                 Column(
    //                   children: [
    //                     AlignText(
    //                       text: 'Message',
    //                       fontWeight: FontWeight.w500,
    //                       fontSize: 16.sp,
    //                     ),
    //                     SimpleTextField(
    //                       hintText: 'Write a message....',
    //                       controller: TextEditingController(),
    //                       validatorType: "email",
    //                     ),
    //                   ],
    //                 ),
    //                 SizedBox(height: 30.h),
    //                 Center(
    //                   child: CustomButton(
    //                     onPressed: () {
    //                       Navigator.pushNamed(
    //                         context,
    //                         RoutesName.BottomNavScreen,
    //                       );
    //                     },
    //                     height: 48.h,
    //                     width: 350.w,
    //                     text: 'Send messages',
    //                     icon: null,
    //                   ),
    //                 ),

    //                 SizedBox(height: 20.h),
    //               ],
    //             ),
    //           ),
    //         ),
    //         Positioned(
    //           top: 30.h,
    //           left: 20.w,
    //           child: InkWell(
    //             onTap: () {
    //               Navigator.pop(context);
    //             },
    //             child: Icon(Icons.arrow_back_ios, color: Colors.white),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
