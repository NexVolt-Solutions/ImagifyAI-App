import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';

/// Simple prompt editor: one text field, copy button. Hint and text at start.
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
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final pad = context.w(16);

    return Container(
      padding: EdgeInsets.fromLTRB(pad, pad, pad, pad),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(context.radius(12)),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            maxLines: 10,
            minLines: 5,
            style: theme.textTheme.bodyMedium?.copyWith(color: onSurface),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: 'Edit your prompt...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: context.subtitleColor,
              ),
            ),
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              onPressed: onCopyTap,
              icon: SvgPicture.asset(AppAssets.copyIcon),
              tooltip: 'Copy prompt',
              style: IconButton.styleFrom(
                minimumSize: const Size(24, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
