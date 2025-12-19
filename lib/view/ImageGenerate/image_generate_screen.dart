import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
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
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
          padding: context.padSym(h: 20),
          children: [
            SizedBox(height: context.h(20)),
            NormalText(
              titleText: "Describe Your Vision",
              titleSize: context.text(16),
              titleWeight: FontWeight.w500,
              titleColor: AppColors.whiteColor,
              titleAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(12)),
            Container(
              width: context.w(double.infinity),
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
                    controller: imageGenerateViewModel.promptController,
                    maxLines: null,
                    style: GoogleFonts.poppins(
                      color: AppColors.whiteColor,
                      fontSize: context.text(12),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Describe the wallpaper you want to create...',
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.textFieldIconColor,
                        fontSize: context.text(12),
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                        bottom: context.h(45),
                        right: context.w(5),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: context.h(8),
                    right: context.w(8),
                    child: GestureDetector(
                      onTap: imageGenerateViewModel.isGettingSuggestion
                          ? null
                          : () => imageGenerateViewModel.getSuggestion(context),
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
                                if (imageGenerateViewModel.isGettingSuggestion)
                                  SizedBox(
                                    height: context.h(17),
                                    width: context.w(17),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.whiteColor,
                                      ),
                                    ),
                                  )
                                else
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
                                    imageGenerateViewModel.isGettingSuggestion
                                        ? 'Loading...'
                                        : 'AI Suggestion',
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
              titleText: "Inspiration Gallery",
              titleSize: context.text(16),
              titleWeight: FontWeight.w500,
              titleColor: AppColors.whiteColor,
              titleAlign: TextAlign.center,
            ),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: PromptContiner(
                    text: 'Unicorn usually shopping at Mall',
                    onTap: () {
                      setState(() {
                        selectedPromptIndex = 0;
                      });
                      // Set the prompt text in the text field
                      imageGenerateViewModel.setPromptText('Unicorn usually shopping at Mall');
                    },
                    isSelected: selectedPromptIndex == 0,
                  ),
                ),
                 Flexible(
                  child: PromptContiner(
                    text: 'Street View of time square',
                    onTap: () {
                      setState(() {
                        selectedPromptIndex = 1;
                      });
                      // Set the prompt text in the text field
                      imageGenerateViewModel.setPromptText('Street View of time square');
                    },
                    isSelected: selectedPromptIndex == 1,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: PromptContiner(
                    text: 'Man stand in front of lake background',
                    onTap: () {
                      setState(() {
                        selectedPromptIndex = 2;
                      });
                      // Set the prompt text in the text field
                      imageGenerateViewModel.setPromptText('Man stand in front of lake background');
                    },
                    isSelected: selectedPromptIndex == 2,
                  ),
                ),
                SizedBox(width: context.w(12)),
                Flexible(
                  child: PromptContiner(
                    text: 'Panda in a lather suit',
                    onTap: () {
                      setState(() {
                        selectedPromptIndex = 3;
                      });
                      // Set the prompt text in the text field
                      imageGenerateViewModel.setPromptText('Panda in a lather suit');
                    },
                    isSelected: selectedPromptIndex == 3,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(20)),
            NormalText(
              titleText: "Choose Your Size",
              titleSize: context.text(16),
              titleWeight: FontWeight.w500,
              titleColor: AppColors.whiteColor,
              titleAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < imageGenerateViewModel.sizes.length; i++) ...[
                  Expanded(
                    child: SizeContiner(
                      text1: imageGenerateViewModel.sizes[i]['text1']!,
                      text2: imageGenerateViewModel.sizes[i]['text2']!,
                      height1: context.h(40),
                      width1: double.infinity, // Will be constrained by Expanded
                      height2: context.h(20),
                      width2: context.w(35), // Slightly wider for longer text
                      isSelected: imageGenerateViewModel.selectedIndex == i,
                      onTap: () {
                        setState(() {
                          imageGenerateViewModel.selectedIndex = i;
                        });
                      },
                    ),
                  ),
                  if (i < imageGenerateViewModel.sizes.length - 1)
                    SizedBox(width: context.w(8)), // Reduced spacing
                ],
              ],
            ),
            SizedBox(height: context.h(20)),
            HomeAlign(text: 'Choose Your Style (Optional)'),
            SizedBox(height: context.h(12)),
            SizedBox(
              height: context.h(100),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageGenerateViewModel.styles.length,
                itemBuilder: (context, index) {
                  final style = imageGenerateViewModel.styles[index];
                  final isSelected = imageGenerateViewModel.selectedStyleIndex == index;
                  return Padding(
                    padding: EdgeInsets.only(right: context.w(10)),
                    child: PromptContiner(
                      text: style,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          imageGenerateViewModel.selectedStyleIndex = isSelected ? -1 : index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: context.h(20)),
            CustomButton(
              onPressed: () => imageGenerateViewModel.createWallpaper(context),
              height: context.h(48),
              width: context.w(350),
              iconHeight: 24,
              iconWidth: 24,
              gradient: AppColors.gradient,
              text: imageGenerateViewModel.isCreating ? 'Crafting Your Masterpiece...' : 'Create Magic',
              icon: AppAssets.magicStarIcon,
            ),
            SizedBox(height: context.h(100)),
          ],
        ),
            // Loading Overlay
            if (imageGenerateViewModel.isCreating)
              _LoadingOverlay(
                progress: imageGenerateViewModel.creationProgress,
              ),
          ],
        ),
      ),
    );
  }
}

// Loading Overlay Widget
class _LoadingOverlay extends StatefulWidget {
  final double progress;

  const _LoadingOverlay({required this.progress});

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay> {
  @override
  Widget build(BuildContext context) {
    final progressPercent = (widget.progress * 100).toInt().clamp(0, 100);
    
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular Progress Indicator
            SizedBox(
              width: context.w(200),
              height: context.h(200),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle (white/grey)
                  SizedBox(
                    width: context.w(200),
                    height: context.h(200),
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: context.w(20),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.3),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  // Progress circle (purple/primary color)
                  SizedBox(
                    width: context.w(200),
                    height: context.h(200),
                    child: CircularProgressIndicator(
                      value: widget.progress,
                      strokeWidth: context.w(20),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primeryColor,
                      ),
                      backgroundColor: Colors.transparent,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Percentage text
                  Text(
                    '$progressPercent%',
                    style: GoogleFonts.poppins(
                      color: AppColors.whiteColor,
                      fontSize: context.text(48),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.h(24)),
            // Loading text
            Text(
              'Creating your Masterpiece...',
              style: GoogleFonts.poppins(
                color: AppColors.whiteColor,
                fontSize: context.text(16),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
