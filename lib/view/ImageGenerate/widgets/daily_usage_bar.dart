import 'dart:async';

import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/models/user/usage_response.dart';
import 'package:imagifyai/viewModel/image_generate_view_model.dart';
import 'package:provider/provider.dart';

const Color _usageGold = Color(0xFFF5C842);

/// Server-backed wallpaper quota (`GET /wallpapers/usage`).
class DailyUsageBar extends StatefulWidget {
  const DailyUsageBar({super.key});

  @override
  State<DailyUsageBar> createState() => _DailyUsageBarState();
}

class _DailyUsageBarState extends State<DailyUsageBar> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageGenerateViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoadingUsage && vm.dailyUsage == null) {
          return Padding(
            padding: EdgeInsets.only(bottom: context.h(8)),
            child: LinearProgressIndicator(
              minHeight: 3,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: context.colorScheme.surfaceContainerHighest,
            ),
          );
        }

        final UsageResponse? u = vm.dailyUsage;
        if (u == null) {
          if (vm.usageLoadError != null) {
            final hint = context.appTextStyles?.imageGeneratePromptHint;
            return Padding(
              padding: EdgeInsets.only(bottom: context.h(8)),
              child: Text(
                vm.usageLoadError!,
                style: hint != null
                    ? hint.copyWith(color: context.colorScheme.error)
                    : TextStyle(color: context.colorScheme.error, fontSize: 13),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        final hintStyle = context.appTextStyles?.imageGeneratePromptHint;
        final limit = u.limit <= 0 ? 1 : u.limit;
        final progress = (u.used / limit).clamp(0.0, 1.0);
        final near = u.remaining <= 3 && u.remaining > 0;
        final reached = u.isHardLimitReached;
        final needAd = u.needsRewardedAdToContinue;
        final accent = reached
            ? context.colorScheme.error
            : needAd
            ? Colors.orange
            : near
            ? Colors.orange
            : _usageGold;

        return Padding(
          padding: EdgeInsets.only(bottom: context.h(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Wallpapers',
                    style: hintStyle,
                  ),
                  Text(
                    '${u.used} / ${u.limit}',
                    style: hintStyle != null
                        ? hintStyle.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w600,
                          )
                        : TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                  ),
                ],
              ),
              SizedBox(height: context.h(6)),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: context.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              ),
              SizedBox(height: context.h(6)),
              if (reached)
                Text(
                  'Limit reached. Resets in ${u.resetCountdown}',
                  style: hintStyle != null
                      ? hintStyle.copyWith(color: context.colorScheme.error)
                      : TextStyle(
                          color: context.colorScheme.error,
                          fontSize: 12,
                        ),
                )
              else if (needAd)
                Text(
                  'Watch a rewarded ad to unlock your next free generations.',
                  style: hintStyle != null
                      ? hintStyle.copyWith(color: Colors.orange)
                      : const TextStyle(color: Colors.orange, fontSize: 12),
                )
              else if (near)
                Text(
                  '${u.remaining} wallpapers remaining in this period',
                  style: hintStyle != null
                      ? hintStyle.copyWith(color: Colors.orange)
                      : const TextStyle(color: Colors.orange, fontSize: 12),
                ),
            ],
          ),
        );
      },
    );
  }
}
