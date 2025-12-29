import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/theme/theme_extensions.dart';

class HomeAlign extends StatelessWidget {
  final String? text;
  const HomeAlign({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
