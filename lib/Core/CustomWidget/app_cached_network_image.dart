import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';

/// Shared headers for wallpaper / CDN image requests.
const kWallpaperImageHeaders = <String, String>{
  'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
  'User-Agent': 'ImagifyAI/1.0 (Flutter)',
};

class AppCachedNetworkImage extends StatelessWidget {
  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.memCacheWidth = 400,
    this.memCacheHeight,
    this.httpHeaders = kWallpaperImageHeaders,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.filterQuality = FilterQuality.low,
    this.useGradientPlaceholder = true,
    this.placeholderBackgroundColor,
    this.errorWidget,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final Map<String, String>? httpHeaders;
  final Duration fadeInDuration;
  final FilterQuality filterQuality;
  final bool useGradientPlaceholder;
  final Color? placeholderBackgroundColor;
  final Widget Function(BuildContext context, String url, Object error)?
  errorWidget;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg =
        placeholderBackgroundColor ??
        scheme.surfaceContainerHighest.withValues(alpha: 0.45);

    Widget placeholder(BuildContext ctx, String url) {
      return ColoredBox(
        color: bg,
        child: Center(
          child: AppLoadingIndicator.medium(
            useGradient: useGradientPlaceholder,
          ),
        ),
      );
    }

    Widget error(BuildContext ctx, String url, Object err) {
      if (errorWidget != null) {
        return errorWidget!(ctx, url, err);
      }
      return ColoredBox(
        color: bg,
        child: const Center(child: Icon(Icons.broken_image_outlined, size: 32)),
      );
    }

    return CachedNetworkImage(
      key: key,
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      httpHeaders: httpHeaders,
      fadeInDuration: fadeInDuration,
      filterQuality: filterQuality,
      placeholder: placeholder,
      errorWidget: error,
    );
  }
}
