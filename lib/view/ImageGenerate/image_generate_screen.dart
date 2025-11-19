import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/CustomWidget/align_text.dart';
import 'package:genwalls/Core/CustomWidget/home_align.dart';
import 'package:genwalls/Core/CustomWidget/icon_custom_button.dart';
import 'package:genwalls/Core/CustomWidget/prompt_continer.dart';
import 'package:genwalls/Core/CustomWidget/size_continer.dart';
import 'package:genwalls/Model/viewModel/image_generate_view_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ImageGenerateScreen extends StatefulWidget {
  const ImageGenerateScreen({super.key});

  @override
  State<ImageGenerateScreen> createState() => _ImageGenerateScreenState();
}

class _ImageGenerateScreenState extends State<ImageGenerateScreen> {
  int selectedPromptIndex = -1;
  int selectedSizeIndex = -1;
  @override
  Widget build(BuildContext context) {
    final imageGenerateViewModel = Provider.of<ImageGenerateViewModel>(context);
    return Scaffold(
      body: Scaffold(
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
                      AlignText(text: 'Enter Prompt'),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                        child: Container(
                          height: 150.h,
                          width: double.infinity.w,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Stack(
                            children: [
                              Scrollbar(
                                child: SingleChildScrollView(
                                  reverse: true,
                                  child: TextFormField(
                                    maxLines: null,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Type Something...',
                                      hintStyle: GoogleFonts.poppins(
                                        color: Colors.grey,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(
                                        right: 1,
                                        top: 8,
                                        bottom: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  height: 32.h,
                                  width: 123.w,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: Colors.purple,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        AppAssets.imageIcon,
                                        height: 16.h,
                                        width: 16.w,
                                        color: Colors.purple,

                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(width: 5.w),
                                      Text(
                                        'AI Suggestion',
                                        style: GoogleFonts.poppins(
                                          color: Colors.purple,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      AlignText(text: 'Try These Prompt:'),
                      PromptContiner(
                        text: 'Unicorn usually shopping at Mall',
                        onTap: () {
                          setState(() {
                            selectedPromptIndex = 0;
                          });
                        },
                        isSelected: selectedPromptIndex == 0,
                      ),
                      PromptContiner(
                        text: 'Street View of time square',
                        onTap: () {
                          setState(() {
                            selectedPromptIndex = 1;
                          });
                        },
                        isSelected: selectedPromptIndex == 1,
                      ),
                      PromptContiner(
                        text: 'Man stand in front of lake background',
                        onTap: () {
                          setState(() {
                            selectedPromptIndex = 2;
                          });
                        },
                        isSelected: selectedPromptIndex == 2,
                      ),
                      PromptContiner(
                        text: 'Panda in a lather suit',
                        onTap: () {
                          setState(() {
                            selectedPromptIndex = 3;
                          });
                        },
                        isSelected: selectedPromptIndex == 3,
                      ),
                      SizedBox(height: 10.h),
                      AlignText(text: 'Select Size'),
                      SizedBox(height: 10.w),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Row(
                              children: [
                                for (int i = 0; i < 2; i++) ...[
                                  SizeContiner(
                                    text1: imageGenerateViewModel
                                        .sizes[i]['text1']!,
                                    text2: imageGenerateViewModel
                                        .sizes[i]['text2']!,
                                    height1: 40.h,
                                    width1: 140.w,
                                    height2: 20.h,
                                    width2: 30.w,
                                    isSelected:
                                        imageGenerateViewModel.selectedIndex ==
                                        i,
                                    onTap: () {
                                      setState(() {
                                        imageGenerateViewModel.selectedIndex =
                                            i;
                                      });
                                    },
                                  ),
                                  SizedBox(width: 10.w),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Row(
                              children: [
                                SizeContiner(
                                  text1:
                                      imageGenerateViewModel.sizes[2]['text1']!,
                                  text2:
                                      imageGenerateViewModel.sizes[2]['text2']!,
                                  height1: 40.h,
                                  width1: 170.w,
                                  height2: 20.h,
                                  width2: 40.w,
                                  isSelected:
                                      imageGenerateViewModel.selectedIndex == 2,
                                  onTap: () {
                                    setState(() {
                                      imageGenerateViewModel.selectedIndex = 2;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.w),
                      HomeAlign(text: 'Art Style (optional)'),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: SizedBox(
                          height: 130.h,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            itemCount: 9,
                            itemBuilder: (context, index) {
                              return Container(
                                height: 130.h,
                                width: 110.w,
                                margin: EdgeInsets.symmetric(horizontal: 10.w),
                                decoration: BoxDecoration(
                                  color: Colors.black, // background black
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                clipBehavior: Clip.hardEdge,

                                child: Column(
                                  children: [
                                    Container(
                                      height: 95.h,
                                      width: 110.w,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        child: Image.asset(
                                          AppAssets.conIcon,
                                          width: 110.w,
                                          height: 95.h,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 10.h),
                                    Text(
                                      "Natural",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                        child: IconCustomButton(
                          onPressed: () {
                            Future.delayed(Duration(seconds: 4), () {
                              imageGenerateViewModel.showStyledNumberDialog(
                                context,
                              );
                            });
                          },
                          height: 48.h,
                          width: 350.w,
                          icon: AppAssets.magicStarIcon,
                          text: 'Do Magic',
                        ),
                      ),
                      SizedBox(height: 100.h),
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
      ),
    );
  }
}
