import 'package:flutter/material.dart';
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';

class ProfileImage extends StatelessWidget {
  final String imagePath;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final bool forceRefresh;

  /// When > 0, appends `v` query param so [Image.network] refetches (same URL, new bytes).
  final int cacheNonce;
  const ProfileImage({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.fit,
    this.forceRefresh = false,
    this.cacheNonce = 0,
  });

  bool get isNetworkImage =>
      imagePath.startsWith('http://') || imagePath.startsWith('https://');

  /// Cache-busting: forceRefresh uses timestamp; cacheNonce uses stable version from view models.
  String get imageUrl {
    if (!isNetworkImage) return imagePath;
    final uri = Uri.parse(imagePath);
    final queryParams = Map<String, String>.from(uri.queryParameters);
    if (forceRefresh) {
      queryParams['_t'] = DateTime.now().millisecondsSinceEpoch.toString();
    }
    if (cacheNonce > 0) {
      queryParams['v'] = cacheNonce.toString();
    }
    if (queryParams.isEmpty) return imagePath;
    return uri.replace(queryParameters: queryParams).toString();
  }

  @override
  Widget build(BuildContext context) {
    // Handle empty image path
    if (imagePath.isEmpty) {
      return ClipOval(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            size: height != null ? height! * 0.6 : 24,
            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return ClipOval(
      child: isNetworkImage
          ? Image.network(
              imageUrl, // Use imageUrl which may include cache-busting
              height: height,
              width: width,
              fit: fit,
              key: ValueKey('$imagePath-$cacheNonce'),
              cacheWidth: width?.toInt(),
              cacheHeight: height?.toInt(),
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: height,
                  width: width,
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: height != null ? height! * 0.6 : 24,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  height: height,
                  width: width,
                  child: Center(child: AppLoadingIndicator.medium()),
                );
              },
            )
          : Image.asset(imagePath, height: height, width: width, fit: fit),
    );
  }
}
