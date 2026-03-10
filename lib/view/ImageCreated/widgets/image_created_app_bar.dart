import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';

class ImageCreatedAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ImageCreatedAppBar({
    super.key,
    this.onReportTap,
  });

  final VoidCallback? onReportTap;

  @override
  Size get preferredSize => const Size.fromHeight(65);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        color: context.backgroundColor,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(AppAssets.starLogo, fit: BoxFit.cover),
              SvgPicture.asset(AppAssets.imagifyaiLogo, fit: BoxFit.cover),
              Positioned(
                left: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).iconTheme.color,
                    size: 20,
                  ),
                ),
              ),
              if (onReportTap != null)
                Positioned(
                  right: 0,
                  child: IconButton(
                    onPressed: onReportTap,
                    icon: Icon(
                      Icons.flag_outlined,
                      color: Theme.of(context).iconTheme.color,
                      size: 22,
                    ),
                    tooltip: 'Report content',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
