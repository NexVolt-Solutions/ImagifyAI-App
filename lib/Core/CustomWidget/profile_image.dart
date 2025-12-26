import 'package:flutter/material.dart';

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
    // Handle empty image path
    if (imagePath.isEmpty) {
      return ClipOval(
        child: Container(
          height: height,
          width: width,
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            size: height != null ? height! * 0.6 : 24,
            color: Colors.white70,
          ),
        ),
      );
    }

    return ClipOval(
      child: isNetworkImage
          ? Image.network(
              imagePath,
              height: height,
              width: width,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: height,
                  width: width,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: height != null ? height! * 0.6 : 24,
                    color: Colors.white70,
                  ),
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
