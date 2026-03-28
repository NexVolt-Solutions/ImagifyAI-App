import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';

class HomeEmptyWallpapers extends StatelessWidget {
  const HomeEmptyWallpapers({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.w(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: context.h(60),
            color: context.subtitleColor.withValues(alpha: 0.5),
          ),
          SizedBox(height: context.h(12)),
          Text(
            'No wallpapers yet',
            style: context.appTextStyles?.homeCardTitle,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.h(8)),
          Text(
            'Create your first wallpaper to see it here!',
            style: context.appTextStyles?.homeCardDescription,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
