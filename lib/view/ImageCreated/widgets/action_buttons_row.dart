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
    required this.onReportTap,
  });

  final ImageCreatedViewModel viewModel;
  final VoidCallback onTryAgainTap;
  final VoidCallback onReportTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: CustomButton(
            onPressed: onTryAgainTap,
            iconHeight: context.h(28),
            gradient: AppColors.gradient,
            text: 'Try Again',
            isLoading: viewModel.isLoading,
            icon: AppAssets.reCreateIcon,
          ),
        ),
        SizedBox(width: context.w(8)),
        Expanded(
          child: CustomButton(
            onPressed: () => viewModel.share(context),
            iconHeight: context.h(24),
            gradient: AppColors.gradient,
            icon: AppAssets.shareIcon,
            text: 'Share',
          ),
        ),
      ],
    );
  }
}
