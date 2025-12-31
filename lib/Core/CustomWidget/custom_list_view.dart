import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/full_screen_image_viewer.dart';
import 'package:genwalls/Core/theme/theme_extensions.dart';
import 'package:genwalls/models/wallpaper/wallpaper.dart';

class CustomListView extends StatelessWidget {
  final String? image;
  final List<Wallpaper>? wallpapers;
  
  const CustomListView({
    super.key,
    this.image,
    this.wallpapers,
  });

  @override
  Widget build(BuildContext context) {
    // If wallpapers list is provided, use it; otherwise use image or placeholder
    final itemCount = wallpapers != null ? wallpapers!.length : (image != null ? 1 : 9);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.h(10)),
      child: SizedBox(
        height: context.h(131),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            // If wallpapers are provided, display them
            if (wallpapers != null && wallpapers!.isNotEmpty) {
              final wallpaper = wallpapers![index];
              final imageUrl = wallpaper.imageUrl.isNotEmpty 
                  ? wallpaper.imageUrl 
                  : (wallpaper.thumbnailUrl.isNotEmpty ? wallpaper.thumbnailUrl : null);
              
              return GestureDetector(
                onTap: () {
                  if (imageUrl != null && imageUrl.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(
                          imageUrl: imageUrl,
                          heroTag: 'wallpaper_${wallpaper.id}_$index',
                        ),
                        fullscreenDialog: true,
                      ),
                    );
                  }
                },
                child: Container(
                  height: context.h(131),
                  width: context.w(100),
                  margin: context.padSym(h: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.radius(8)),
                    border: Border.all(color: context.colorScheme.onSurface),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(context.radius(8)),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Hero(
                            tag: 'wallpaper_${wallpaper.id}_$index',
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: context.colorScheme.surface,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: context.colorScheme.onSurface.withOpacity(0.5),
                                    size: 40,
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: context.colorScheme.surface,
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
                          )
                        : Container(
                            color: context.colorScheme.surface,
                            child: Icon(
                              Icons.image_not_supported,
                              color: context.colorScheme.onSurface.withOpacity(0.5),
                              size: 40,
                            ),
                          ),
                  ),
                ),
              );
            }
            
            // Fallback to image or placeholder
            return Container(
              height: context.h(131),
              width: context.w(100),
              margin: context.padSym(h: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.radius(8)),
                border: Border.all(color: context.colorScheme.onSurface),
              ),
              clipBehavior: Clip.hardEdge,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.radius(8)),
                child: image != null && image!.isNotEmpty
                    ? Image.asset(image!, fit: BoxFit.contain)
                    : Container(
                        color: context.colorScheme.surface,
                        child: Icon(
                          Icons.image_not_supported,
                          color: context.colorScheme.onSurface.withOpacity(0.5),
                          size: 40,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
