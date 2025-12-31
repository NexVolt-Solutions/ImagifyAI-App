import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/full_screen_image_viewer.dart';
import 'package:genwalls/Core/theme/theme_extensions.dart';
import 'package:genwalls/models/wallpaper/wallpaper.dart';

class CategoryDetailsScreen extends StatelessWidget {
  final String categoryName;
  final List<Wallpaper> wallpapers;

  const CategoryDetailsScreen({
    super.key,
    required this.categoryName,
    required this.wallpapers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: context.textColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          categoryName,
          style: context.appTextStyles?.homeAlignText,
        ),
        centerTitle: true,
      ),
      body: wallpapers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: context.h(60),
                    color: context.subtitleColor.withOpacity(0.5),
                  ),
                  SizedBox(height: context.h(12)),
                  Text(
                    'No wallpapers available',
                    style: context.appTextStyles?.homeCardTitle,
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(context.h(20)),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: context.w(12),
                mainAxisSpacing: context.h(12),
                childAspectRatio: 0.75,
              ),
              itemCount: wallpapers.length,
              itemBuilder: (context, index) {
                final wallpaper = wallpapers[index];
                final imageUrl = wallpaper.imageUrl.isNotEmpty
                    ? wallpaper.imageUrl
                    : (wallpaper.thumbnailUrl.isNotEmpty
                        ? wallpaper.thumbnailUrl
                        : null);

                if (imageUrl == null || imageUrl.isEmpty) {
                  return Container(
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(context.radius(12)),
                    ),
                    child: Icon(
                      Icons.image_not_supported,
                      color: context.subtitleColor,
                      size: 40,
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(
                          imageUrl: imageUrl,
                          heroTag: 'category_${wallpaper.id}_$index',
                        ),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'category_${wallpaper.id}_$index',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(context.radius(12)),
                        border: Border.all(
                          color: context.colorScheme.onSurface.withOpacity(0.3),
                        ),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: context.surfaceColor,
                            child: Icon(
                              Icons.image_not_supported,
                              color: context.subtitleColor,
                              size: 40,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: context.surfaceColor,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

