import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';
import 'package:imagifyai/Core/CustomWidget/home_align.dart';
import 'package:imagifyai/Core/CustomWidget/prompt_continer.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/image_generate_view_model.dart';
import 'package:provider/provider.dart';

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
                  child: Text(
                    'Failed to load styles',
                    style: context.appTextStyles?.homeCardDescription,
                  ),
                ),
              );
            }
            return SizedBox(
              height: context.h(100),
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: vm.styles.length,
                itemBuilder: (context, index) {
                  final style = vm.styles[index];
                  final isSelected = vm.selectedStyleIndex == index;
                  return Padding(
                    padding: EdgeInsets.only(right: context.w(10)),
                    child: PromptContiner(
                      text: style,
                      isSelected: isSelected,
                      onTap: () {
                        vm.setSelectedStyle(index, context);
                        if (!isSelected) onScrollToStyle(index);
                      },
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
