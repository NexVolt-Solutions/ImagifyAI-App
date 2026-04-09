import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/custom_button.dart';
import 'package:imagifyai/Core/CustomWidget/loading_overlay.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/Core/services/content_report_service.dart';
import 'package:imagifyai/view/ImageGenerate/widgets/daily_limit_dialog.dart';
import 'package:imagifyai/view/ImageGenerate/widgets/daily_usage_bar.dart';
import 'package:imagifyai/view/ImageGenerate/widgets/rewarded_wallpaper_quota_flow.dart';
import 'package:imagifyai/view/ImageGenerate/widgets/image_generate_prompt_section.dart';
import 'package:imagifyai/view/ImageGenerate/widgets/inspiration_gallery.dart';
import 'package:imagifyai/view/ImageGenerate/widgets/size_selector_row.dart';
import 'package:imagifyai/view/ImageGenerate/widgets/style_selector_list.dart';
import 'package:imagifyai/Core/CustomWidget/ad_banner_widget.dart';
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
  bool _hasClearedOnEnter = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasClearedOnEnter) {
      _hasClearedOnEnter = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ImageGenerateViewModel>().clearPromptAndSelections();
        }
      });
    }
    if (!_hasLoadedStyles) {
      _hasLoadedStyles = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vm = context.read<ImageGenerateViewModel>();
        vm.loadStyles(context);
        vm.loadDailyUsage(context);
      });
    }
  }

  @override
  void dispose() {
    _styleScrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedStyle(int styleIndex, BuildContext context) {
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
    final vm = context.read<ImageGenerateViewModel>();
    final u = vm.dailyUsage;

    if (u != null && u.isHardLimitReached) {
      if (!context.mounted) return;
      DailyLimitDialog.show(context, usage: u);
      return;
    }

    if (u != null && u.remaining > 0) {
      vm.createWallpaper(context);
      return;
    }

    if (u != null && u.needsRewardedAdToContinue) {
      if (!context.mounted) return;
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            'Watch a short ad',
            style: context.appTextStyles?.imageGenerateSectionTitle,
          ),
          content: Text(
            'Unlock your next free generations. Progress syncs automatically after the ad.',
            style: context.appTextStyles?.imageGeneratePromptText,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: context.primaryColor),
              ),
            ),
            TextButton(
              onPressed: () async {
                await RewardedWallpaperQuotaFlow.runWatchAdUnlockSequence(
                  context: context,
                  dialogToDismissOnReward: dialogContext,
                  onUnlocked: () async {
                    if (!mounted) return;
                    vm.createWallpaper(context);
                  },
                );
              },
              child: Text(
                'Watch ad',
                style: TextStyle(color: context.primaryColor),
              ),
            ),
          ],
        ),
      );
      return;
    }

    vm.createWallpaper(context);
  }

  @override
  Widget build(BuildContext context) {
    final imageGenerateViewModel = Provider.of<ImageGenerateViewModel>(context);
    // Scaffold supplies Material so TextField works when this screen is opened
    // as a standalone route (e.g. pushNamed). Safe inside bottom nav too.
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
                    const DailyUsageBar(),
                    CustomButton(
                      onPressed: imageGenerateViewModel.isCreating ||
                              (imageGenerateViewModel.dailyUsage?.isHardLimitReached ==
                                  true)
                          ? null
                          : () => _onCreateMagicTapped(context),
                      width: context.w(350),
                      iconHeight: 24,
                      iconWidth: 24,
                      gradient: AppColors.gradient,
                      icon: AppAssets.startIcon,
                      text: imageGenerateViewModel.dailyUsage?.isHardLimitReached ==
                              true
                          ? 'Daily Limit Reached'
                          : imageGenerateViewModel.dailyUsage
                                      ?.needsRewardedAdToContinue ==
                                  true
                              ? 'Watch ad to continue'
                              : 'Generate',
                      isLoading: imageGenerateViewModel.isCreating,
                    ),
                    SizedBox(height: context.h(16)),
                    Center(
                      child: GestureDetector(
                        onTap: () =>
                            ContentReportService.showReportInfoDialog(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              size: 16,
                              color: context.subtitleColor,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Report offensive content',
                              style: TextStyle(
                                color: context.subtitleColor,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: context.h(16)),
                    AdBannerWidget(
                      key: const ValueKey('image_generate_banner'),
                    ),
                    SizedBox(height: context.h(106)),
                  ],
                ),
              ),
            ),
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
