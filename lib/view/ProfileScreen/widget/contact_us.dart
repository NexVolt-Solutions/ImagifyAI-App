import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/CustomWidget/align_text.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_row.dart';
import 'package:genwalls/Model/utils/Routes/routes_name.dart';
import 'package:genwalls/view/ProfileScreen/widget/privacy_policy.dart';
import 'package:genwalls/view/ProfileScreen/widget/term_of_use.dart';
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
                    SizedBox(height: 10.h),
                    Text(
                      'Contact Us',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Any question or remarks? Just write us a message!',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Image.asset(
                              AppAssets.phoneIcon,
                              height: 30.h,
                              width: 30.w,
                            ),
                            Text(
                              '+1012 3456 789',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Image.asset(
                              AppAssets.emailIcon,
                              height: 30.h,
                              width: 30.w,
                            ),
                            Text(
                              'demo@gmail.com',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Column(
                      children: [
                        AlignText(
                          text: 'First Name',
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                        SimpleTextField(
                          hintText: 'Ahmad',
                          controller: TextEditingController(),
                          validatorType: "name",
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Column(
                      children: [
                        AlignText(
                          text: 'Last Name',
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                        SimpleTextField(
                          hintText: 'Khan',
                          controller: TextEditingController(),
                          validatorType: "name",
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Column(
                      children: [
                        AlignText(
                          text: 'Phone Number',
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                        SimpleTextField(
                          hintText: '0316XXXXXXX',
                          controller: TextEditingController(),
                          validatorType: "phone",
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Column(
                      children: [
                        AlignText(
                          text: 'Email',
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                        SimpleTextField(
                          hintText: 'Khan@gmail.com',
                          controller: TextEditingController(),
                          validatorType: "email",
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select Subject?",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          Wrap(
                            spacing: 30.w,
                            runSpacing: 20.h,
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
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 12.r,
                                            )
                                          : null,
                                    ),

                                    SizedBox(width: 8.w),

                                    Text(
                                      subjects[index],
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10.h),
                    Column(
                      children: [
                        AlignText(
                          text: 'Message',
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                        SimpleTextField(
                          hintText: 'Write a message....',
                          controller: TextEditingController(),
                          validatorType: "email",
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
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
                        text: 'Send messages',
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

class SimpleTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String validatorType; // name, phone, email

  const SimpleTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.validatorType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: TextFormField(
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        controller: controller,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "This field is required";
          }
          if (validatorType == "name") {
            if (value.length < 3) {
              return "Enter a valid name";
            }
          }
          if (validatorType == "phone") {
            if (!RegExp(r'^[0-9]{10,13}$').hasMatch(value)) {
              return "Enter a valid phone number";
            }
          }
          if (validatorType == "email") {
            if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$").hasMatch(value)) {
              return "Enter a valid email";
            }
          }

          return null;
        },
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class SubjectRow extends StatelessWidget {
  final text1;
  final text2;
  final text3;
  final text4;
  const SubjectRow({super.key, this.text1, this.text2, this.text3, this.text4});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 10.r,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.check, color: Colors.black, size: 12.sp),
                ),
                SizedBox(width: 10.w),
                Text(
                  text1,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 10.r,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.check, color: Colors.black, size: 12.sp),
                ),
                SizedBox(width: 10.w),
                Text(
                  text2,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 10.r,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.check, color: Colors.black, size: 12.sp),
                ),
                SizedBox(width: 10.w),
                Text(
                  text3,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 10.r,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.check, color: Colors.black, size: 12.sp),
                ),
                SizedBox(width: 10.w),
                Text(
                  text4,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
