import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';
import 'package:imagifyai/Core/CustomWidget/custom_button.dart';
import 'package:imagifyai/Core/CustomWidget/home_align.dart';
import 'package:imagifyai/Core/CustomWidget/prompt_continer.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/image_generate_view_model.dart';
import 'package:provider/provider.dart';

String? _styleImagePath(String styleName) {
  switch (styleName) {
    case 'Colorful':
      return AppAssets.imageColorful;
    case '3D Render':
      return AppAssets.image3DRender;
    case 'Photorealistic':
      return AppAssets.imagePhotorealistic;
    case 'Oil Painting':
      return AppAssets.imageOil;
    case 'Watercolor':
      return AppAssets.imageWaterColor;
    case 'Cyberpunk':
      return AppAssets.imageNeon;
    case 'Fantasy':
      return AppAssets.imageFantasy;
    case 'Anime':
      return AppAssets.imageAnime;
    case 'Cartoon':
      return AppAssets.imageCartoon;
    case 'Steampunk':
      return AppAssets.imageSteampunk;
    case 'Pixel Art':
      return AppAssets.imagePixel;
    case 'Low Poly':
      return AppAssets.imageLowPoly;
    case 'Isometric':
      return AppAssets.imageIsometric;
    case 'Minimalist':
      return AppAssets.imageMinimalistic;
    case 'Synthwave':
      return AppAssets.imageSynthwave;
    case 'Retro Futurism':
      return AppAssets.imageRetroFuturism;
    case 'Solarpunk':
      return AppAssets.imageSolarPunk;
    case 'Game Art':
      return AppAssets.imageGameArt;
    default:
      return null;
  }
}

class StyleSelectorList extends StatelessWidget {
  final ScrollController scrollController;
  final void Function(int index) onScrollToStyle;

  const StyleSelectorList({
    super.key,
    required this.scrollController,
    required this.onScrollToStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeAlign(text: 'Choose Your Style (Optional)'),
        SizedBox(height: context.h(12)),
        Consumer<ImageGenerateViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoadingStyles) {
              return SizedBox(
                height: context.h(100),
                child: Center(child: AppLoadingIndicator.medium()),
              );
            }
            if (vm.stylesError != null) {
              return SizedBox(
                height: context.h(100),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Failed to load styles',
                        style: context.appTextStyles?.homeCardDescription,
                      ),
                      CustomButton(
                        text: 'Retry',
                        onPressed: () {
                          vm.loadStyles(context);
                          onScrollToStyle(vm.selectedStyleIndex);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
            return SizedBox(
              height: context.h(130),
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: vm.styles.length,
                itemBuilder: (context, index) {
                  final style = vm.styles[index];
                  final isSelected = vm.selectedStyleIndex == index;
                  return Padding(
                    padding: EdgeInsets.only(right: context.w(12)),
                    child: PromptContiner(
                      text: style,
                      isSelected: isSelected,
                      onTap: () {
                        vm.setSelectedStyle(index, context);
                        if (!isSelected) onScrollToStyle(index);
                      },
                      imagePath: _styleImagePath(style),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
