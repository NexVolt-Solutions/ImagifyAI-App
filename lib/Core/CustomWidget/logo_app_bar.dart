import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';

/// Shared app bar with star + ImagifyAI logo. Optional [trailing] for e.g. Skip button.
class LogoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? trailing;

  const LogoAppBar({super.key, this.trailing});

  @override
  Size get preferredSize => const Size.fromHeight(65);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.backgroundColor,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(AppAssets.starLogo, fit: BoxFit.cover),
            SvgPicture.asset(AppAssets.imagifyaiLogo, fit: BoxFit.cover),
            if (trailing != null) Positioned(right: 0, child: trailing!),
          ],
        ),
      ),
    );
  }
}
