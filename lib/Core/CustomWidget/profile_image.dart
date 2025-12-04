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

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(imagePath, height: height, width: width, fit: fit),
    );
  }
}
