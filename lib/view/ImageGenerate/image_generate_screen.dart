import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/custom_button.dart';
import 'package:imagifyai/Core/CustomWidget/loading_overlay.dart';
import 'package:imagifyai/Core/services/generation_limit_service.dart';
import 'package:imagifyai/Core/services/rewarded_ad_service.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:imagifyai/view/ImageGenerate/widgets/image_generate_prompt_section.dart';
import 'package:imagifyai/view/ImageGenerate/widgets/inspiration_gallery.dart';
import 'package:imagifyai/view/ImageGenerate/widgets/limit_and_watch_ad_row.dart';
import 'package:imagifyai/view/ImageGenerate/widgets/size_selector_row.dart';
import 'package:imagifyai/view/ImageGenerate/widgets/style_selector_list.dart';
import 'package:imagifyai/viewModel/image_generate_view_model.dart';
import 'package:provider/provider.dart';

class ImageGenerateScreen extends StatefulWidget {
  const ImageGenerateScreen({super.key});

  @override
  State<ImageGenerateScreen> createState() => _ImageGenerateScreenState();
}

class _ImageGenerateScreenState extends State<ImageGenerateScreen> {
  final ScrollController _styleScrollController = ScrollController();
  bool _hasLoadedStyles = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedStyles) {
      _hasLoadedStyles = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ImageGenerateViewModel>().loadStyles(context);
      });
    }
  }

  @override
  void dispose() {
    _styleScrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedStyle(int styleIndex, BuildContext context) {
    // Wait for the next frame to ensure the ListView is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_styleScrollController.hasClients && styleIndex >= 0) {
        final baseItemWidth =
            140.0; // Base width (padding + border + some text)
        final scrollPosition = (styleIndex * baseItemWidth).clamp(
          0.0,
          _styleScrollController.position.maxScrollExtent,
        );

        // Center the selected item in the viewport if possible
        final viewportWidth = MediaQuery.of(context).size.width;
        final centeredPosition =
            (scrollPosition - viewportWidth / 2 + baseItemWidth / 2).clamp(
              0.0,
              _styleScrollController.position.maxScrollExtent,
            );

        _styleScrollController.animateTo(
          centeredPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _scrollToStyleByName(String styleName, BuildContext context) {
    final viewModel = context.read<ImageGenerateViewModel>();
    final styleIndex = viewModel.getStyleIndexByName(styleName);
    if (styleIndex != null) {
      _scrollToSelectedStyle(styleIndex, context);
    }
  }

  Future<void> _onCreateMagicTapped(BuildContext context) async {
    final can = await GenerationLimitService.canGenerate();
    if (!mounted) return;
    if (can) {
      context.read<ImageGenerateViewModel>().createWallpaper(context);
      return;
    }
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Daily limit reached',
          style: context.appTextStyles?.imageGenerateSectionTitle,
        ),
        content: Text(
          'You\'ve used your free generations for today. Watch a short ad for 1 more?',
          style: context.appTextStyles?.imageGeneratePromptText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: context.primaryColor)),
          ),
          TextButton(
            onPressed: () async {
              final shown = await RewardedAdService.showRewardedAd(
                onReward: () {
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  context.read<ImageGenerateViewModel>().createWallpaper(context);
                },
              );
              if (!dialogContext.mounted) return;
              if (!shown) {
                SnackbarUtil.showTopSnackBar(
                  dialogContext,
                  'Ad not ready. Try again in a moment.',
                  isError: true,
                );
              }
            },
            child: Text('Watch ad', style: TextStyle(color: context.primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageGenerateViewModel = Provider.of<ImageGenerateViewModel>(context);
    return Scaffold(
      backgroundColor: context.backgroundColor,

      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(20)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.h(20)),
                    ImageGeneratePromptSection(),
                    SizedBox(height: context.h(20)),
                    InspirationGallery(
                      onScrollToStyle: (name) =>
                          _scrollToStyleByName(name, context),
                    ),
                    SizedBox(height: context.h(20)),
                    SizeSelectorRow(),
                    SizedBox(height: context.h(20)),
                    StyleSelectorList(
                      scrollController: _styleScrollController,
                      onScrollToStyle: (index) =>
                          _scrollToSelectedStyle(index, context),
                    ),
                    SizedBox(height: context.h(20)),
                    CustomButton(
                      onPressed: () => _onCreateMagicTapped(context),
                      width: context.w(350),
                      iconHeight: 24,
                      iconWidth: 24,
                      gradient: AppColors.gradient,
                      text: 'Create Magic',
                      icon: AppAssets.magicStarIcon,
                      isLoading: imageGenerateViewModel.isCreating,
                    ),
                    SizedBox(height: context.h(12)),
                    LimitAndWatchAdRow(),
                    SizedBox(height: context.h(100)),
                  ],
                ),
              ),
            ),
            // Loading Overlay
            if (imageGenerateViewModel.isCreating)
              Consumer<ImageGenerateViewModel>(
                builder: (context, vm, _) => LoadingOverlay(
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

