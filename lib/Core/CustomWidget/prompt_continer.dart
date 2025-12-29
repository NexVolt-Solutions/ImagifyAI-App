import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/theme/theme_extensions.dart';

class PromptContiner extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const PromptContiner({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.h(4)),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
           decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.radius(8)),
            border: Border.all(
              color: isSelected ? context.colorScheme.primary : context.colorScheme.onSurface,
              width: context.w(1.5),
            ),
          ),
          padding: context.padSym(h: 12, v: 4),

          child: Text(
            text,
            style: context.appTextStyles?.promptContainerText,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
