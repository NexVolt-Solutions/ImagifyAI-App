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
            iconHeight: context.h(32),
            gradient: AppColors.gradient,
            text: 'Try Again',
            isLoading: viewModel.isLoading,
            icon: AppAssets.reCreateIcon,
          ),
        ),
        SizedBox(width: context.w(12)),

        Expanded(
          child: CustomButton(
            onPressed: () => viewModel.share(context),
            iconHeight: context.h(28),
            gradient: AppColors.gradient,
            icon: AppAssets.shareIcon,

            text: 'Share',
          ),
        ),
      ],
    );
  }
}
