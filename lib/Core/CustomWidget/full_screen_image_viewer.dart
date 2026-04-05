import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';
import 'package:imagifyai/Core/services/content_report_service.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:imagifyai/models/wallpaper/wallpaper.dart';
import 'package:path_provider/path_provider.dart';

class FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? heroTag;
  final Wallpaper? wallpaper;

  /// URL already decoded in the list row (thumbnail preferred). Shown under the
  /// full image so opening preview does not flash a loader when only the full
  /// URL still needs to load.
  final String? previewBackdropUrl;

  /// Must match the list thumbnail [Image.network] cache sizes when possible so
  /// the backdrop hits [ImageCache] instantly for same-URL opens.
  final int? previewBackdropCacheWidth;
  final int? previewBackdropCacheHeight;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    this.heroTag,
    this.wallpaper,
    this.previewBackdropUrl,
    this.previewBackdropCacheWidth,
    this.previewBackdropCacheHeight,
  });

  static void show(
    BuildContext context,
    String imageUrl, {
    String? heroTag,
    Wallpaper? wallpaper,
    String? previewBackdropUrl,
    int? previewBackdropCacheWidth,
    int? previewBackdropCacheHeight,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          imageUrl: imageUrl,
          heroTag: heroTag,
          wallpaper: wallpaper,
          previewBackdropUrl: previewBackdropUrl,
          previewBackdropCacheWidth: previewBackdropCacheWidth,
          previewBackdropCacheHeight: previewBackdropCacheHeight,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  static const _kImageHeaders = <String, String>{
    'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
    'User-Agent': 'ImagifyAI/1.0 (Flutter)',
  };

  bool _isDownloading = false;

  Future<void> _downloadImage() async {
    if (_isDownloading) return;
    final url = widget.imageUrl;
    if (url.isEmpty || url == 'null') {
      SnackbarUtil.showTopSnackBar(
        context,
        'Image is not ready yet. Please try again in a moment',
      );
      return;
    }

    setState(() => _isDownloading = true);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }
      await _saveImageToDevice(response.bodyBytes);
      if (!mounted) return;
      SnackbarUtil.showTopSnackBar(
        context,
        'Saved to your device! Enjoy your new wallpaper',
        isError: false,
      );
    } catch (_) {
      if (!mounted) return;
      SnackbarUtil.showTopSnackBar(
        context,
        'Couldn\'t save your wallpaper right now. Let\'s try again!',
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _saveImageToDevice(Uint8List imageBytes) async {
    final id =
        widget.wallpaper?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final baseName = 'ImagifyAI_wallpaper_$id';
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$baseName.png');
    await file.writeAsBytes(imageBytes);
    await Gal.putImage(file.path);
  }

  String _trimUrl(String? u) {
    final s = u?.trim() ?? '';
    if (s.isEmpty || s == 'null') return '';
    return s;
  }

  /// URL for the underlay: list row preview (explicit), else thumbnail, else same as [main].
  String _resolveBackdropUrl(String main) {
    final explicit = _trimUrl(widget.previewBackdropUrl);
    if (explicit.isNotEmpty) return explicit;
    final w = widget.wallpaper;
    if (w != null) {
      final t = _trimUrl(w.thumbnailUrl);
      if (t.isNotEmpty) return t;
    }
    return main;
  }

  Widget _imageBody(BuildContext context) {
    final main = _trimUrl(widget.imageUrl);
    if (main.isEmpty) {
      return Container(
        color: Colors.grey[900],
        child: const Icon(Icons.person, size: 100, color: Colors.white70),
      );
    }

    final backdropUrl = _resolveBackdropUrl(main);

    return Image.network(
      backdropUrl,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      headers: _kImageHeaders,

      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.iconColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (widget.wallpaper != null)
            IconButton(
              icon: Icon(Icons.flag_outlined, color: context.iconColor),
              tooltip: 'Report content',
              onPressed: () {
                final w = widget.wallpaper!;
                ContentReportService.showReportDialog(
                  context,
                  contentId: w.id,
                  imageUrl: w.imageUrl.isNotEmpty && w.imageUrl != 'null'
                      ? w.imageUrl
                      : widget.imageUrl,
                  prompt: w.prompt,
                  sourceLabel: 'Full screen viewer',
                );
              },
            ),
          IconButton(
            onPressed: _isDownloading ? null : _downloadImage,
            icon: _isDownloading
                ? AppLoadingIndicator.medium(color: context.iconColor)
                : Icon(Icons.download_outlined, color: context.iconColor),
          ),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            alignment: Alignment.center,
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight * 0.9,
              child: _imageBody(context),
            ),
          );
        },
      ),
    );
  }
}
