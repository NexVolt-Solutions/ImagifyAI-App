import 'package:flutter/material.dart';
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';
import 'package:imagifyai/Core/services/content_report_service.dart';
import 'package:imagifyai/models/wallpaper/wallpaper.dart';

class FullScreenImageViewer extends StatelessWidget {
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
          if (wallpaper != null)
            IconButton(
              icon: const Icon(Icons.flag_outlined, color: Colors.white),
              tooltip: 'Report content',
              onPressed: () {
                final w = wallpaper!;
                ContentReportService.showReportDialog(
                  context,
                  contentId: w.id,
                  imageUrl: w.imageUrl.isNotEmpty && w.imageUrl != 'null' ? w.imageUrl : imageUrl,
                  prompt: w.prompt,
                  sourceLabel: 'Full screen viewer',
                );
              },
            ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: heroTag ?? imageUrl,
            child: imageUrl.isEmpty
                ? Container(
                    color: Colors.grey[900],
                    child: const Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.white70,
                    ),
                  )
                : Image.network(
                    imageUrl,
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
