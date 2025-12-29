import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/home_align.dart';
import 'package:genwalls/Core/CustomWidget/prompt_continer.dart';
import 'package:genwalls/Core/CustomWidget/size_continer.dart';
import 'package:genwalls/Core/theme/theme_extensions.dart';
import 'package:genwalls/viewModel/image_generate_view_model.dart';
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
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
          padding: context.padSym(h: 20),
          children: [
            SizedBox(height: context.h(20)),
            Text(
              "Describe Your Vision",
              style: context.appTextStyles?.imageGenerateSectionTitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(12)),
            Container(
              width: context.w(double.infinity),
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(context.radius(8)),
                border: Border.all(
                  color: context.colorScheme.onSurface,
                  width: context.h(1.5),
                ),
              ),
              padding: context.padAll(12),
              child: Stack(
                children: [
                  TextFormField(
                    controller: imageGenerateViewModel.promptController,
                    maxLines: 4,
                    minLines: 1,
                    enabled: true,
                    readOnly: false,
                    style: context.appTextStyles?.imageGeneratePromptText,
                    decoration: InputDecoration(
                      hintText: 'Describe the wallpaper you want to create...',
                      hintStyle: context.appTextStyles?.imageGeneratePromptHint,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                        bottom: context.h(45),
                        right: context.w(5),
                      ),
                    ),
                    maxLength: null,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
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
                          color: context.backgroundColor,
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
                                color: context.colorScheme.onSurface,
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
                                        context.textColor,
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
                                    style: context.appTextStyles?.imageGenerateAISuggestion,
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
            Text(
              "Inspiration Gallery",
              style: context.appTextStyles?.imageGenerateSectionTitle,
              textAlign: TextAlign.center,
            ),
            
            Wrap(
              spacing: context.w(8),
              runSpacing: context.h(4),
              children: [
                PromptContiner(
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
                PromptContiner(
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
                PromptContiner(
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
                PromptContiner(
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
              ],
            ),
            SizedBox(height: context.h(20)),
            Text(
              "Choose Your Size",
              style: context.appTextStyles?.imageGenerateSectionTitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < imageGenerateViewModel.sizes.length; i++) ...[
                  Expanded(
                    child: SizeContiner(
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
              Consumer<ImageGenerateViewModel>(
                builder: (context, vm, _) => _LoadingOverlay(
                  progress: vm.creationProgress,
                  currentStage: vm.currentStage,
                  elapsedTime: vm.elapsedPollingTimeFormatted,
                ),
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
  final String currentStage;
  final String elapsedTime;

  const _LoadingOverlay({
    required this.progress,
    required this.currentStage,
    required this.elapsedTime,
  });

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  String _displayedStage = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _displayedStage = widget.currentStage;
    _fadeController.forward();
  }

  @override
  void didUpdateWidget(_LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStage != widget.currentStage) {
      // Fade out old stage
      _fadeController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _displayedStage = widget.currentStage;
          });
          // Fade in new stage
          _fadeController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressPercent = (widget.progress * 100).toInt().clamp(0, 100);
    
    return Container(
      color: context.backgroundColor.withOpacity(0.9),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(40)),
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
                          context.textColor.withOpacity(0.3),
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
                          context.primaryColor,
                        ),
                        backgroundColor: Colors.transparent,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    // Percentage text
                    Text(
                      '$progressPercent%',
                      style: context.appTextStyles?.imageGenerateLoadingPercent,
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.h(32)),
              // Main title
              Text(
                'Generating your wallpaper...',
                style: context.appTextStyles?.imageGenerateLoadingTitle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.h(16)),
              // Current stage with fade animation
              FadeTransition(
                opacity: _fadeController,
                child: Text(
                  _displayedStage,
                  style: context.appTextStyles?.imageGenerateLoadingStage,
                  textAlign: TextAlign.center,
                ),
              ),
              // Elapsed time (only show if polling)
              if (widget.elapsedTime.isNotEmpty) ...[
                SizedBox(height: context.h(8)),
                Text(
                  'Elapsed: ${widget.elapsedTime}',
                  style: context.appTextStyles?.imageGenerateLoadingTime,
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: context.h(40)),
              // Progress stages indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStageIndicator(
                    context,
                    'Preparing',
                    widget.progress >= 0.0,
                  ),
                  SizedBox(width: context.w(8)),
                  _buildStageConnector(context, widget.progress >= 0.2),
                  SizedBox(width: context.w(8)),
                  _buildStageIndicator(
                    context,
                    'Rendering',
                    widget.progress >= 0.4,
                  ),
                  SizedBox(width: context.w(8)),
                  _buildStageConnector(context, widget.progress >= 0.6),
                  SizedBox(width: context.w(8)),
                  _buildStageIndicator(
                    context,
                    'Finalizing',
                    widget.progress >= 0.8,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageIndicator(BuildContext context, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: context.w(12),
          height: context.h(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? context.primaryColor
                : context.textColor.withOpacity(0.3),
            border: Border.all(
              color: isActive
                  ? context.primaryColor
                  : context.textColor.withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
        SizedBox(height: context.h(4)),
        Text(
          label,
          style: (context.appTextStyles?.imageGenerateStageLabel)?.copyWith(
            color: isActive
                ? context.primaryColor
                : context.textColor.withOpacity(0.5),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStageConnector(BuildContext context, bool isActive) {
    return Container(
      width: context.w(20),
      height: context.h(2),
      decoration: BoxDecoration(
        color: isActive
            ? context.primaryColor
            : context.textColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
