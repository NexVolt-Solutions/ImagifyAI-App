import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:lottie/lottie.dart';

class LoadingOverlay extends StatefulWidget {
  final double progress;
  final String currentStage;
  final String elapsedTime;

  const LoadingOverlay({
    super.key,
    required this.progress,
    required this.currentStage,
    required this.elapsedTime,
  });

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  String _displayedStage = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _displayedStage = widget.currentStage;
    _fadeController.forward();
  }

  @override
  void didUpdateWidget(LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStage != widget.currentStage) {
      _fadeController.reverse().then((_) {
        if (mounted) {
          setState(() => _displayedStage = widget.currentStage);
          _fadeController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.backgroundColor.withValues(alpha: 0.92),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(28)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final gap = context.h(16);
              final rowReserve = context.h(12) + context.h(4) + context.h(14) + gap;
              final maxLottieH = (constraints.maxHeight - rowReserve)
                  .clamp(100.0, context.h(620));
              final lottieW = math.min(context.w(560), constraints.maxWidth);
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: lottieW,
                    height: maxLottieH,
                    child: Lottie.asset(
                      AppAssets.loadingAnimationLottie,
                      fit: BoxFit.contain,
                      repeat: true,
                      frameRate: FrameRate.max,
                    ),
                  ),
                  SizedBox(height: gap),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStageIndicator(
                        context,
                        'Preparing',
                        widget.progress >= 0.0,
                      ),
                      SizedBox(width: context.w(8)),
                      _buildStageConnector(context, widget.progress >= 0.2),
                      SizedBox(width: context.w(8)),
                      _buildStageIndicator(
                        context,
                        'Rendering',
                        widget.progress >= 0.4,
                      ),
                      SizedBox(width: context.w(8)),
                      _buildStageConnector(context, widget.progress >= 0.6),
                      SizedBox(width: context.w(8)),
                      _buildStageIndicator(
                        context,
                        'Finalizing',
                        widget.progress >= 0.8,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStageIndicator(
    BuildContext context,
    String label,
    bool isActive,
  ) {
    return Column(
      children: [
        Container(
          width: context.w(12),
          height: context.h(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? context.primaryColor
                : context.textColor.withValues(alpha: 0.3),
            border: Border.all(
              color: isActive
                  ? context.primaryColor
                  : context.textColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
        ),
        SizedBox(height: context.h(4)),
        Text(
          label,
          style: (context.appTextStyles?.imageGenerateStageLabel)?.copyWith(
            color: isActive
                ? context.primaryColor
                : context.textColor.withValues(alpha: 0.5),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStageConnector(BuildContext context, bool isActive) {
    return Container(
      width: context.w(20),
      height: context.h(2),
      decoration: BoxDecoration(
        color: isActive
            ? context.primaryColor
            : context.textColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
