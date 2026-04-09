import 'dart:async';

import 'package:flutter/material.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/models/user/usage_response.dart';
import 'package:imagifyai/viewModel/bottom_nav_screen_view_model.dart';
import 'package:provider/provider.dart';

/// Shown when the user hits the server-side daily wallpaper quota (HTTP 429).
class DailyLimitDialog extends StatefulWidget {
  const DailyLimitDialog({
    super.key,
    required this.usage,
    this.popRouteAfterExplore = false,
  });

  final UsageResponse? usage;
  final bool popRouteAfterExplore;

  static Future<void> show(
    BuildContext context, {
    UsageResponse? usage,
    bool popRouteAfterExplore = false,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => DailyLimitDialog(
        usage: usage,
        popRouteAfterExplore: popRouteAfterExplore,
      ),
    );
  }

  @override
  State<DailyLimitDialog> createState() => _DailyLimitDialogState();
}

class _DailyLimitDialogState extends State<DailyLimitDialog> {
  Timer? _timer;
  DateTime? _resetsAtUtc;

  @override
  void initState() {
    super.initState();
    _resetsAtUtc = widget.usage?.resetsAt;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _liveCountdown() {
    final at = _resetsAtUtc;
    if (at == null) return 'a few hours';
    final now = DateTime.now().toUtc();
    var diff = at.difference(now);
    if (diff.isNegative) diff = Duration.zero;
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }

  void _onExplore() {
    BottomNavScreenViewModel? bottomNav;
    try {
      bottomNav = context.read<BottomNavScreenViewModel>();
    } catch (_) {}
    final rootNav = Navigator.of(context, rootNavigator: true);
    Navigator.of(context).pop();
    bottomNav?.updateIndex(0);
    if (widget.popRouteAfterExplore && rootNav.canPop()) {
      rootNav.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFF5C842);
    return AlertDialog(
      backgroundColor: context.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.primaryColor.withValues(alpha: 0.3)),
      ),
      title: Row(
        children: [
          Icon(Icons.hourglass_empty, color: gold, size: 26),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Daily Limit Reached',
              style: context.appTextStyles?.imageGenerateSectionTitle,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have used all ${widget.usage?.limit ?? 10} wallpapers for today.',
            style: context.appTextStyles?.imageGeneratePromptText,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, color: gold, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Resets in ${_liveCountdown()}',
                    style: TextStyle(
                      color: gold,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'While you wait, explore wallpapers created by other users!',
            style: context.appTextStyles?.imageGeneratePromptHint,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'OK',
            style: TextStyle(color: context.subtitleColor),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: Colors.black,
          ),
          onPressed: _onExplore,
          child: const Text('Explore Wallpapers'),
        ),
      ],
    );
  }
}
