import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/prompt_continer.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/image_generate_view_model.dart';
import 'package:provider/provider.dart';

/// Prompt + style pairs using API style names (from fetchStyles).
/// Style names must match backend: Colorful, 3D Render, Photorealistic, etc.
class _InspirationPrompts {
  static const List<({String prompt, String style})> items = [
    (prompt: 'A sunset by the sea', style: 'Photorealistic'),
    (prompt: 'Neon city at night', style: 'Cyberpunk'),
    (prompt: 'Starry sky above', style: '3D Render'),
    (prompt: 'A cozy forest', style: 'Fantasy'),
    (prompt: 'Cute cartoon character', style: 'Cartoon'),
    (prompt: 'Anime character portrait', style: 'Anime'),
  ];
}

class InspirationGallery extends StatelessWidget {
  final void Function(String styleName) onScrollToStyle;

  const InspirationGallery({super.key, required this.onScrollToStyle});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ImageGenerateViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Inspiration Gallery",
          style: context.appTextStyles?.imageGenerateSectionTitle,
          textAlign: TextAlign.center,
        ),
        Wrap(
          spacing: context.w(8),
          runSpacing: context.h(4),
          children: [
            for (var i = 0; i < _InspirationPrompts.items.length; i++)
              _buildChip(
                context,
                vm,
                _InspirationPrompts.items[i].prompt,
                _InspirationPrompts.items[i].style,
                i,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context,
    ImageGenerateViewModel vm,
    String prompt,
    String styleName,
    int promptIndex,
  ) {
    return PromptContiner(
      text: prompt,
      onTap: () {
        vm.setPromptWithDefaults(prompt, styleName, promptIndex);
        onScrollToStyle(styleName);
      },
      isSelected: vm.selectedPromptIndex == promptIndex,
    );
  }
}
