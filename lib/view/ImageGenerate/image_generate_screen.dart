import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_list_view.dart';
import 'package:genwalls/Core/CustomWidget/home_align.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';
import 'package:genwalls/Core/CustomWidget/prompt_continer.dart';
import 'package:genwalls/Core/CustomWidget/size_continer.dart';
import 'package:genwalls/viewModel/image_generate_view_model.dart';
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
                padding: context.padSym(h: 20),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 24,
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
          padding: context.padSym(h: 20),
          children: [
            SizedBox(height: context.h(20)),
            NormalText(
              titleText: "Enter Prompt",
              titleSize: context.text(16),
              titleWeight: FontWeight.w500,
              titleColor: AppColors.whiteColor,
              titleAlign: TextAlign.center,
            ),

            SizedBox(height: context.h(12)),
            Container(
              // height: context.h(148),
              width: double.infinity.w,
              decoration: BoxDecoration(
                color: AppColors.blackColor,
                borderRadius: BorderRadius.circular(context.radius(8)),
                border: Border.all(
                  color: AppColors.whiteColor,
                  width: context.h(1.5),
                ),
              ),
              padding: context.padAll(12),
              child: Stack(
                children: [
                  TextFormField(
                    maxLines: null,
                    style: GoogleFonts.poppins(
                      color: AppColors.whiteColor,
                      fontSize: context.text(12),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type Something...',
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.textFieldIconColor,
                        fontSize: context.text(12),
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.only(top: context.h(104)),
                      child: Container(
                        height: context.h(32),
                        width: context.w(123),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(
                            context.radius(8),
                          ),
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return AppColors.gradient.createShader(bounds);
                          },
                          blendMode: BlendMode.srcIn,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                context.radius(8),
                              ),
                              border: Border.all(
                                color: AppColors.whiteColor,
                                width: context.w(1.5),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      AppColors.gradient.createShader(bounds),
                                  blendMode: BlendMode.srcIn,
                                  child: Image.asset(
                                    AppAssets.imageIcon,
                                    height: context.h(17),
                                    width: context.w(17),
                                    color: Colors.white,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(width: context.w(4)),
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      AppColors.gradient.createShader(bounds),
                                  blendMode: BlendMode.srcIn,
                                  child: Text(
                                    'AI Suggestion',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.whiteColor,
                                      fontSize: context.text(12),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.h(20)),
            NormalText(
              titleText: "Try These Prompt:",
              titleSize: context.text(16),
              titleWeight: FontWeight.w500,
              titleColor: AppColors.whiteColor,
              titleAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
              ],
            ),
            SizedBox(height: 20.h),
            NormalText(
              titleText: "Select Size",
              titleSize: context.text(16),
              titleWeight: FontWeight.w500,
              titleColor: AppColors.whiteColor,
              titleAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(12)),
            Row(
              children: [
                for (int i = 0; i < 2; i++) ...[
                  SizeContiner(
                    text1: imageGenerateViewModel.sizes[i]['text1']!,
                    text2: imageGenerateViewModel.sizes[i]['text2']!,
                    height1: context.h(40),
                    width1: context.w(140),
                    height2: context.h(20),
                    width2: context.w(30),

                    isSelected: imageGenerateViewModel.selectedIndex == i,
                    onTap: () {
                      setState(() {
                        imageGenerateViewModel.selectedIndex = i;
                      });
                    },
                  ),
                  SizedBox(width: context.w(10)),
                ],
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                SizeContiner(
                  text1: imageGenerateViewModel.sizes[2]['text1']!,
                  text2: imageGenerateViewModel.sizes[2]['text2']!,
                  height1: context.h(40),
                  width1: context.w(170),
                  height2: context.h(20),
                  width2: context.w(40),
                  isSelected: imageGenerateViewModel.selectedIndex == 2,
                  onTap: () {
                    setState(() {
                      imageGenerateViewModel.selectedIndex = 2;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: context.h(20)),
            HomeAlign(text: 'Art Style (optional)'),
            SizedBox(height: context.h(12)),
            CustomListView(image: AppAssets.conIcon),
            SizedBox(height: context.h(20)),
            CustomButton(
              onPressed: () {
                Future.delayed(Duration(seconds: 4), () {
                  imageGenerateViewModel.showStyledNumberDialog(context);
                });
              },
              height: context.h(48),
              width: context.w(350),
              iconHeight: 24,
              iconWidth: 24,
              gradient: AppColors.gradient,
              text: 'Do Magic',
              icon: AppAssets.magicStarIcon,
            ),

            SizedBox(height: context.h(100)),
          ],
        ),
      ),
    );
  }
}
