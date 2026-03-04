import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/custom_button.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';

class GenerateWallpaperCard extends StatelessWidget {
  final VoidCallback onGenerateTap;
  final bool isLoading;

  const GenerateWallpaperCard({
    super.key,
    required this.onGenerateTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.h(20)),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: const [10, 10],
          strokeWidth: context.w(1),
          radius: Radius.circular(context.radius(12)),
          color: context.colorScheme.onSurface.withOpacity(0.6),
        ),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(context.w(20)),
          children: [
            Container(
              padding: EdgeInsets.all(context.w(14)),
              decoration: BoxDecoration(
                color: context.colorScheme.onSurface,
                shape: BoxShape.circle,
                gradient: AppColors.gradient,
              ),
              child: SvgPicture.asset(AppAssets.startIcon, fit: BoxFit.scaleDown),
            ),
            SizedBox(height: context.h(12)),
            Text(
              'Create Your Perfect Wallpaper',
              style: context.appTextStyles?.homeCardTitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(12)),
            Text(
              'Use AI to generate stunning wallpapers tailored to your style. From abstract art to breathtaking landscapes.',
              style: context.appTextStyles?.homeCardDescription,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(12)),
            CustomButton(
              onPressed: onGenerateTap,
              height: context.h(47),
              width: context.w(160),
              gradient: AppColors.gradient,
              text: 'Generate Now',
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
