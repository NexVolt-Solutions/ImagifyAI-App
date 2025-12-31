import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/theme/theme_extensions.dart';

class HomeAlign extends StatelessWidget {
  final String? text;
  final VoidCallback? onTap;
  const HomeAlign({super.key, this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text!,
            style: context.appTextStyles?.homeAlignText,
          ),
          Icon(
            Icons.arrow_forward_ios_outlined,
            color: Theme.of(context).iconTheme.color,
            size: context.h(15),
          ),
        ],
      ),
    );
  }
}
