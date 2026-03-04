import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';

class PromptEditorCard extends StatelessWidget {
  const PromptEditorCard({
    super.key,
    required this.controller,
    required this.onCopyTap,
  });

  final TextEditingController controller;
  final VoidCallback onCopyTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.padAll(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(context.radius(12)),
      ),
      child: Stack(
        children: [
          TextFormField(
            controller: controller,
            maxLines: 4,
            minLines: 1,
            enabled: true,
            readOnly: false,
            style: context.appTextStyles?.imageCreatedPromptText,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter your prompt...',
              hintStyle: context.appTextStyles?.imageCreatedPromptHint,
              contentPadding: EdgeInsets.only(
                bottom: context.h(30),
                right: context.w(40),
                left: context.w(10),
                top: context.h(10),
              ),
            ),
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
          ),
          Positioned(
            bottom: context.h(10),
            right: context.w(10),
            child: GestureDetector(
              onTap: onCopyTap,
              child: Icon(Icons.copy, color: context.textColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
