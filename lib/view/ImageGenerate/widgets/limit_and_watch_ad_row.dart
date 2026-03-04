import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/services/generation_limit_service.dart';
import 'package:imagifyai/Core/services/rewarded_ad_service.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';

/// Row showing daily usage (X/5) and "Watch ad for +1" button.
class LimitAndWatchAdRow extends StatelessWidget {
  const LimitAndWatchAdRow({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: Future.wait([
        GenerationLimitService.getGenerationsUsedToday(),
        RewardedAdService.getFreeGenerationsFromAds(),
      ]).then((v) => {'used': v[0], 'adCredits': v[1]}),
      builder: (context, snapshot) {
        final used = snapshot.data?['used'] ?? 0;
        final adCredits = snapshot.data?['adCredits'] ?? 0;
        final limit = GenerationLimitService.dailyLimit;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Free today: $used/$limit${adCredits > 0 ? ' • $adCredits from ads' : ''}',
              style: context.appTextStyles?.imageGeneratePromptHint.copyWith(
                color: context.textColor,
              ),
            ),
            SizedBox(height: context.h(4)),
            TextButton.icon(
              onPressed: () => _onWatchAd(context),
              icon: Icon(Icons.play_circle_outline, size: 20, color: context.primaryColor),
              label: Text(
                'Watch ad for +1',
                style: context.appTextStyles?.imageGeneratePromptHint.copyWith(
                  color: context.primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _onWatchAd(BuildContext context) async {
    final shown = await RewardedAdService.showRewardedAd(
      onReward: () {
        if (!context.mounted) return;
        SnackbarUtil.showTopSnackBar(
          context,
          'You earned 1 free generation!',
          isError: false,
        );
      },
    );
    if (!context.mounted) return;
    if (!shown) {
      SnackbarUtil.showTopSnackBar(
        context,
        'Ad not ready. Please try again in a moment.',
        isError: true,
      );
    }
  }
}
