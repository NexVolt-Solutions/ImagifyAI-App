import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/size_continer.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/image_generate_view_model.dart';
import 'package:provider/provider.dart';

class SizeSelectorRow extends StatelessWidget {
  const SizeSelectorRow({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ImageGenerateViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Choose Your Size",
          style: context.appTextStyles?.imageGenerateSectionTitle,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.h(12)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 0; i < vm.sizes.length; i++) ...[
              Expanded(
                child: SizeContiner(
                  text2: vm.sizes[i]['text2']!,
                  height1: context.h(40),
                  width1: double.infinity,
                  height2: context.h(20),
                  width2: context.w(35),
                  isSelected: vm.selectedIndex == i,
                  onTap: () => vm.setSelectedSize(i),
                ),
              ),
              if (i < vm.sizes.length - 1) SizedBox(width: context.w(8)),
            ],
          ],
        ),
      ],
    );
  }
}
