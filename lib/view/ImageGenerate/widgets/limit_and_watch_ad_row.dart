import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:imagifyai/view/ImageGenerate/widgets/rewarded_wallpaper_quota_flow.dart';
import 'package:imagifyai/viewModel/image_generate_view_model.dart';
import 'package:provider/provider.dart';

/// Server-backed remaining generations and “Watch ad” (SSV grants credits on the backend).
class LimitAndWatchAdRow extends StatelessWidget {
  const LimitAndWatchAdRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageGenerateViewModel>(
      builder: (context, vm, _) {
        final u = vm.dailyUsage;
        final hint = context.appTextStyles?.imageGeneratePromptHint;
        if (u == null) {
          return const SizedBox.shrink();
        }

        final line = StringBuffer('Free left: ${u.remaining}');
        if (u.initialFreeRemaining != null || u.postAdFreeRemaining != null) {
          line.write(' • ');
          if (u.initialFreeRemaining != null) {
            line.write('First block: ${u.initialFreeRemaining}');
          }
          if (u.postAdFreeRemaining != null) {
            if (u.initialFreeRemaining != null) line.write(' · ');
            line.write('After ad: ${u.postAdFreeRemaining}');
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              line.toString(),
              style: hint?.copyWith(color: context.textColor),
            ),
            if (u.needsRewardedAdToContinue) ...[
              SizedBox(height: context.h(4)),
              TextButton.icon(
                onPressed: () => RewardedWallpaperQuotaFlow.runWatchAdUnlockSequence(
                  context: context,
                  onUnlocked: () async {
                    SnackbarUtil.showTopSnackBar(
                      context,
                      'You can generate again!',
                      isError: false,
                    );
                  },
                ),
                icon: Icon(
                  Icons.play_circle_outline,
                  size: 20,
                  color: context.primaryColor,
                ),
                label: Text(
                  'Watch ad for more',
                  style: hint?.copyWith(color: context.primaryColor),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
