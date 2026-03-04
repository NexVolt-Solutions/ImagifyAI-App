import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/models/user/user.dart';

/// Pinned sliver header showing user avatar and greeting.
class UserProfileHeader extends StatelessWidget {
  final User? currentUser;
  final String displayName;
  final bool isProfileLoading;

  const UserProfileHeader({
    super.key,
    required this.currentUser,
    required this.displayName,
    this.isProfileLoading = false,
  });

  static String getDisplayName(User? user) {
    if (user == null) return 'User';
    if (user.username != null && user.username!.isNotEmpty) {
      return user.username!;
    }
    final fullName = user.fullName;
    if (fullName.isNotEmpty && fullName != 'User') return fullName;
    if (user.firstName != null && user.firstName!.isNotEmpty) {
      return user.firstName!;
    }
    if (user.email != null && user.email!.isNotEmpty) {
      final parts = user.email!.split('@');
      if (parts.isNotEmpty) return parts[0];
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _UserProfileHeaderDelegate(
        height: 65.0,
        child: ListTile(
          contentPadding: EdgeInsets.only(left: context.w(20)),
          leading: _buildLeading(context),
          title: Text(
            'Hello, $displayName 👋',
            style: context.appTextStyles?.homeGreetingTitle,
          ),
          subtitle: Text(
            'Ready to build your perfect wallpaper?',
            style: context.appTextStyles?.homeGreetingSubtitle,
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    if (isProfileLoading) {
      return Container(
        height: context.h(50),
        width: context.h(50),
        decoration: BoxDecoration(
          color: context.subtitleColor.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: const Center(child: AppLoadingIndicator.small()),
      );
    }
    final url = currentUser?.profileImageUrl;
    final hasUrl = url != null && url.isNotEmpty;
    if (hasUrl) {
      return ClipOval(
        child: Image.network(
          url,
          height: context.h(50),
          width: context.h(50),
          fit: BoxFit.cover,
          key: ValueKey(url),
          cacheWidth: context.h(50).toInt(),
          cacheHeight: context.h(50).toInt(),
          errorBuilder: (_, __, ___) => _buildPlaceholder(context),

          loadingBuilder: (_, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: context.h(50),
              width: context.h(50),
              decoration: BoxDecoration(
                color: context.subtitleColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Center(child: AppLoadingIndicator.small()),
            );
          },
        ),
      );
    }
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: context.h(50),
      width: context.h(50),
      decoration: BoxDecoration(
        color: context.subtitleColor.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: context.h(30),
        color: context.textColor.withOpacity(0.7),
      ),
    );
  }
}

class _UserProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _UserProfileHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      height: height,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(_UserProfileHeaderDelegate oldDelegate) {
    return child != oldDelegate.child || height != oldDelegate.height;
  }
}
