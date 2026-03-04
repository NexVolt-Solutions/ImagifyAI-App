import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';

class PromptContiner extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  /// Optional asset path for style preview image (e.g. for Choose Your Style cards).
  final String? imagePath;

  const PromptContiner({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: hasImage ? 0 : context.h(4),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: hasImage ? context.w(100) : null,
          height: hasImage ? context.h(130) : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.radius(10)),
            border: Border.all(
              color: isSelected
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurface,
              width: context.w(1.5),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          padding: hasImage ? EdgeInsets.zero : context.padSym(h: 12, v: 4),
          child: hasImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(context.radius(10)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Image.asset(
                          imagePath!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      Padding(
                        padding: context.padSym(h: 6, v: 6),
                        child: Text(
                          text,
                          style: context.appTextStyles?.promptContainerText,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              : Text(
                  text,
                  style: context.appTextStyles?.promptContainerText,
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}
