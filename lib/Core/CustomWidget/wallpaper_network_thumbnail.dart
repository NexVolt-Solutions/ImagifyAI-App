import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';
import 'package:imagifyai/models/wallpaper/wallpaper.dart';

/// Decodes list thumbnails with fallbacks (dead thumbnail → full image) and
/// guards against zero cache sizes / stuck downloads.
class WallpaperNetworkThumbnail extends StatefulWidget {
  const WallpaperNetworkThumbnail({
    super.key,
    required this.wallpaper,
    required this.cacheWidth,
    required this.cacheHeight,
  });

  final Wallpaper wallpaper;
  final int cacheWidth;
  final int cacheHeight;

  @override
  State<WallpaperNetworkThumbnail> createState() =>
      _WallpaperNetworkThumbnailState();
}

class _WallpaperNetworkThumbnailState extends State<WallpaperNetworkThumbnail> {
  static const _kImageHeaders = <String, String>{
    'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
    'User-Agent': 'ImagifyAI/1.0 (Flutter)',
  };

  late List<String> _urls;
  int _urlIndex = 0;
  Timer? _stuckTimer;
  bool _loadedSuccessfully = false;
  bool _gaveUpOnSlowLoad = false;

  @override
  void initState() {
    super.initState();
    _urls = _dedupedUrls(widget.wallpaper);
    _scheduleStuckFallback();
  }

  @override
  void didUpdateWidget(covariant WallpaperNetworkThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.wallpaper.id != widget.wallpaper.id ||
        oldWidget.wallpaper.thumbnailUrl != widget.wallpaper.thumbnailUrl ||
        oldWidget.wallpaper.imageUrl != widget.wallpaper.imageUrl) {
      _urlIndex = 0;
      _loadedSuccessfully = false;
      _gaveUpOnSlowLoad = false;
      _urls = _dedupedUrls(widget.wallpaper);
      _scheduleStuckFallback();
    }
  }

  List<String> _dedupedUrls(Wallpaper w) {
    final out = <String>[];
    void add(String? u) {
      final s = u?.trim() ?? '';
      if (s.isEmpty || s == 'null') return;
      if (out.contains(s)) return;
      out.add(s);
    }

    add(w.thumbnailUrl);
    add(w.imageUrl);
    return out;
  }

  void _scheduleStuckFallback() {
    _stuckTimer?.cancel();
    if (_urls.isEmpty || _loadedSuccessfully || _gaveUpOnSlowLoad) return;
    _stuckTimer = Timer(const Duration(seconds: 14), () {
      if (!mounted || _loadedSuccessfully) return;
      if (_urlIndex < _urls.length - 1) {
        setState(() {
          _urlIndex++;
          _loadedSuccessfully = false;
        });
        _scheduleStuckFallback();
      } else {
        setState(() => _gaveUpOnSlowLoad = true);
      }
    });
  }

  @override
  void dispose() {
    _stuckTimer?.cancel();
    super.dispose();
  }

  Widget _thumbnailLoading(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      child: const Center(
        child: AppLoadingIndicator.medium(useGradient: true),
      ),
    );
  }

  Widget _emptyOrBroken(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 32,
          color: scheme.onSurface.withValues(alpha: 0.28),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_urls.isEmpty || _gaveUpOnSlowLoad) return _emptyOrBroken(context);

    final url = _urls[_urlIndex.clamp(0, _urls.length - 1)];
    final cw = widget.cacheWidth.clamp(64, 4096);
    final ch = widget.cacheHeight.clamp(64, 4096);

    return CachedNetworkImage(
      imageUrl: url,
      key: ValueKey<String>('${widget.wallpaper.id}|$url'),
      httpHeaders: _kImageHeaders,
      fit: BoxFit.cover,
      memCacheWidth: cw,
      memCacheHeight: ch,
      filterQuality: FilterQuality.low,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: (_, __) => _thumbnailLoading(context),
      errorWidget: (_, __, ___) {
        final hasNext = _urlIndex < _urls.length - 1;
        if (hasNext) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _urlIndex++;
              _loadedSuccessfully = false;
            });
            _scheduleStuckFallback();
          });
          return _thumbnailLoading(context);
        }
        return _emptyOrBroken(context);
      },
      imageBuilder: (context, imageProvider) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _loadedSuccessfully) return;
          _loadedSuccessfully = true;
          _stuckTimer?.cancel();
        });
        return Image(
          image: imageProvider,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          gaplessPlayback: true,
        );
      },
    );
  }
}
