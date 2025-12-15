import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';

class ProfileImage extends StatelessWidget {
  final String imagePath;
  final double? height;
  final double? width;
  final BoxFit? fit;
  const ProfileImage({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.fit,
  });

  bool get isNetworkImage => imagePath.startsWith('http://') || imagePath.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: isNetworkImage
          ? Image.network(
              imagePath,
              height: height,
              width: width,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  AppAssets.conIcon,
                  height: height,
                  width: width,
                  fit: fit,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  height: height,
                  width: width,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            )
          : Image.asset(imagePath, height: height, width: width, fit: fit),
    );
  }
}
