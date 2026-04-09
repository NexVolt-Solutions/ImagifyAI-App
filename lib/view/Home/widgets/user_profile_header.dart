import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/app_cached_network_image.dart';
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/models/user/user.dart';

/// Pinned sliver header showing user avatar and greeting.
class UserProfileHeader extends StatelessWidget {
  final User? currentUser;
  final String displayName;
  final bool isProfileLoading;
  final int profileImageCacheNonce;

  const UserProfileHeader({
    super.key,
    required this.currentUser,
    required this.displayName,
    this.isProfileLoading = false,
    this.profileImageCacheNonce = 0,
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
        height: 80.0,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: context.w(20)),
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
          color: context.subtitleColor.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: const Center(child: AppLoadingIndicator.small()),
      );
    }
    final url = currentUser?.profileImageUrl;
    final hasUrl = url != null && url.isNotEmpty;
    if (hasUrl) {
      final imageUrl = _avatarUrlWithCacheNonce(url, profileImageCacheNonce);
      final dim = context.h(50).round();
      return ClipOval(
        child: AppCachedNetworkImage(
          key: ValueKey('$url-$profileImageCacheNonce'),
          imageUrl: imageUrl,
          height: context.h(50),
          width: context.h(50),
          fit: BoxFit.cover,
          memCacheWidth: dim,
          memCacheHeight: dim,
          useGradientPlaceholder: false,
          errorWidget: (_, __, ___) => _buildPlaceholder(context),
        ),
      );
    }
    return _buildPlaceholder(context);
  }

  static String _avatarUrlWithCacheNonce(String url, int nonce) {
    if (nonce <= 0) return url;
    final uri = Uri.parse(url);
    final q = Map<String, String>.from(uri.queryParameters)..['v'] = '$nonce';
    return uri.replace(queryParameters: q).toString();
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: context.h(50),
      width: context.h(50),
      decoration: BoxDecoration(
        color: context.subtitleColor.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: context.h(30),
        color: context.textColor.withValues(alpha: 0.7),
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
