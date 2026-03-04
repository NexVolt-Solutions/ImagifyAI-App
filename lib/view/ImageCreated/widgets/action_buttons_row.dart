import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/custom_button.dart';
import 'package:imagifyai/viewModel/image_created_view_model.dart';

class ActionButtonsRow extends StatelessWidget {
  const ActionButtonsRow({
    super.key,
    required this.viewModel,
    required this.onTryAgainTap,
  });

  final ImageCreatedViewModel viewModel;
  final VoidCallback onTryAgainTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            onPressed: onTryAgainTap,
            iconHeight: 24,
            iconWidth: 24,
            gradient: AppColors.gradient,
            text: 'Try Again',
            isLoading: viewModel.isLoading,
            icon: AppAssets.reCreateIcon,
          ),
        ),
        SizedBox(width: context.w(12)),
        Expanded(
          child: CustomButton(
            onPressed: () => viewModel.saveToDevice(context),
            iconHeight: 24,
            iconWidth: 24,
            gradient: AppColors.gradient,
            text: 'Save',
            isLoading: viewModel.isDownloading,
            icon: AppAssets.downloadIcon,
          ),
        ),
        SizedBox(width: context.w(12)),
        Expanded(
          child: CustomButton(
            onPressed: () => viewModel.share(context),
            iconHeight: 24,
            iconWidth: 24,
            gradient: AppColors.gradient,
            text: 'Share',
          ),
        ),
      ],
    );
  }
}
