import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';
import 'package:imagifyai/Core/services/content_report_service.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:imagifyai/models/wallpaper/wallpaper.dart';
import 'package:path_provider/path_provider.dart';

class FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? heroTag;
  final Wallpaper? wallpaper;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    this.heroTag,
    this.wallpaper,
  });

  static void show(
    BuildContext context,
    String imageUrl, {
    String? heroTag,
    Wallpaper? wallpaper,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          imageUrl: imageUrl,
          heroTag: heroTag,
          wallpaper: wallpaper,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (widget.wallpaper != null)
            IconButton(
              icon: const Icon(Icons.flag_outlined, color: Colors.white),
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
          FloatingActionButton(
            onPressed: _isDownloading ? null : _downloadImage,
            backgroundColor: Colors.black.withValues(alpha: 0.65),
            child: _isDownloading
                ? const AppLoadingIndicator.medium(color: Colors.white)
                : Icon(Icons.download_outlined, color: Colors.white),
          ),
        ],
      ),

      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: widget.heroTag ?? widget.imageUrl,
            child: widget.imageUrl.isEmpty
                ? Container(
                    color: Colors.grey[900],
                    child: const Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.white70,
                    ),
                  )
                : Image.network(
                    widget.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: AppLoadingIndicator.medium(color: Colors.white),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[900],
                        child: const Icon(
                          Icons.error_outline,
                          size: 100,
                          color: Colors.white70,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
