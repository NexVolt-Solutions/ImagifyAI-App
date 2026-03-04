import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/prompt_continer.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/image_generate_view_model.dart';
import 'package:provider/provider.dart';

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
            _buildChip(context, vm, 'Abstract neon cityscape at night', 'Cyberpunk', 0),
            _buildChip(context, vm, 'Serene mountain landscape with sunset', 'Photorealistic', 1),
            _buildChip(context, vm, 'Cosmic galaxy with stars and nebula', '3D Render', 2),
            _buildChip(context, vm, 'Minimalist geometric patterns', 'Illustration', 3),
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
