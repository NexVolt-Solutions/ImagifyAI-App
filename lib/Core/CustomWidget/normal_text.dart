import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';

class NormalText extends StatelessWidget {
  final String? titleText;
  final String? subText;

  final double? titleSize;
  final double? subSize;

  final FontWeight? titleWeight;
  final FontWeight? subWeight;

  final Color? titleColor;
  final Color? subColor;

  final TextAlign? titleAlign;
  final TextAlign? subAlign;
  final CrossAxisAlignment? crossAxisAlignment;

  const NormalText({
    super.key,
    this.titleText,
    this.subText,
    this.titleSize,
    this.subSize,
    this.titleWeight,
    this.subWeight,
    this.titleColor,
    this.subColor,
    this.titleAlign,
    this.subAlign,
    this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      children: [
        if (titleText != null)
          Text(
            titleText!,
            style:
                (titleColor != null
                        ? (context.appTextStyles?.normalTextTitle ??
                                  TextStyle())
                              .copyWith(color: titleColor)
                        : context.appTextStyles?.normalTextTitle)
                    ?.copyWith(
                      fontSize: titleSize ?? context.text(16),
                      fontWeight: titleWeight ?? FontWeight.w500,
                    ) ??
                TextStyle(
                  fontSize: titleSize ?? context.text(16),
                  fontWeight: titleWeight ?? FontWeight.w500,
                  color: titleColor,
                ),
            textAlign: titleAlign ?? TextAlign.start,
          ),

        if (subText != null)
          Text(
            subText!,
            style:
                (subColor != null
                        ? (context.appTextStyles?.normalTextSubtitle ??
                                  TextStyle())
                              .copyWith(color: subColor)
                        : context.appTextStyles?.normalTextSubtitle)
                    ?.copyWith(
                      fontSize: subSize ?? context.text(14),
                      fontWeight: subWeight ?? FontWeight.w400,
                    ) ??
                TextStyle(
                  fontSize: subSize ?? context.text(14),
                  fontWeight: subWeight ?? FontWeight.w400,
                  color: subColor,
                ),
            textAlign: subAlign ?? TextAlign.start,
          ),
      ],
    );
  }
}
