import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';

class CustomTextRich extends StatelessWidget {
  const CustomTextRich({
    super.key,
    this.text1,
    this.text2,
    this.textSize1,
    this.textSize2,
    this.onTap2,
  });
  final String? text1;
  final String? text2;
  final double? textSize1;
  final double? textSize2;
  final VoidCallback? onTap2;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.padSym(h: 10, v: 5),
      child: Align(
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: text1,
                style: context.appTextStyles?.customTextRichText1.copyWith(
                  fontSize: textSize1 ?? textSize2 ?? context.text(14),
                ),
              ),
              TextSpan(
                text: text2,
                style: context.appTextStyles?.customTextRichText2.copyWith(
                  fontSize: textSize2 ?? context.text(14),
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    onTap2?.call();
                  },
              ),
            ],
          ),

          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
