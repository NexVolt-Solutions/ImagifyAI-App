import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/image_generate_view_model.dart';
import 'package:provider/provider.dart';

class ImageGeneratePromptSection extends StatelessWidget {
  const ImageGeneratePromptSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ImageGenerateViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              color: context.colorScheme.primary,
              width: context.h(1.5),
            ),
          ),
          padding: context.padAll(12),
          child: Stack(
            children: [
              TextFormField(
                controller: vm.promptController,
                maxLines: 4,
                minLines: 1,
                enabled: true,
                readOnly: false,
                style: context.appTextStyles?.imageGeneratePromptText,
                decoration: InputDecoration(
                  hintText: 'Describe the wallpaper you want to create...',
                  hintStyle: context.appTextStyles?.imageGeneratePromptHint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
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
                  onTap: vm.isGettingSuggestion
                      ? null
                      : () => vm.getSuggestion(context),
                  child: Container(
                    height: context.h(32),
                    width: context.w(123),
                    decoration: BoxDecoration(
                      color: context.backgroundColor,
                      borderRadius: BorderRadius.circular(context.radius(8)),
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
                            color: context.colorScheme.primary,
                            width: context.w(1.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (vm.isGettingSuggestion)
                              AppLoadingIndicator.small(
                                color: context.textColor,
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
                                  color: context.iconColor,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            SizedBox(width: context.w(4)),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppColors.gradient.createShader(bounds),
                              blendMode: BlendMode.srcIn,
                              child: Text(
                                vm.isGettingSuggestion
                                    ? 'Loading...'
                                    : 'AI Suggestion',
                                style: context
                                    .appTextStyles
                                    ?.imageGenerateAISuggestion,
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
      ],
    );
  }
}
