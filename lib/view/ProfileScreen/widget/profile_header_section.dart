import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/full_screen_image_viewer.dart';
import 'package:imagifyai/Core/CustomWidget/profile_image.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/models/user/user.dart';

class ProfileHeaderSection extends StatelessWidget {
  final User? user;
  final int profileImageCacheNonce;

  const ProfileHeaderSection({
    super.key,
    required this.user,
    this.profileImageCacheNonce = 0,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = user?.profileImageUrl ?? '';
    final heroTag = 'profile_image_${user?.id ?? 'default'}';
    return Column(
      children: [
        SizedBox(height: context.h(20)),
        Center(
          child: GestureDetector(
            onTap: () {
              if (imageUrl.isNotEmpty) {
                FullScreenImageViewer.show(
                  context,
                  imageUrl,
                  heroTag: heroTag,
                );
              }
            },
            child: Hero(
              tag: heroTag,
              child: ProfileImage(
                imagePath: imageUrl,
                height: context.h(100),
                width: context.h(100),
                fit: BoxFit.cover,
                cacheNonce: profileImageCacheNonce,
              ),
            ),
          ),
        ),
        SizedBox(height: context.h(12)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              user?.fullName ?? "User",
              style: context.appTextStyles?.profileName,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(4)),
            Text(
              user?.email ?? "",
              style: context.appTextStyles?.profileEmail,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}
