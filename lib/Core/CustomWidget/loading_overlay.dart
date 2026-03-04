import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';

/// Full-screen overlay showing creation progress (used by ImageGenerate and ImageCreated).
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
    final progressPercent = (widget.progress * 100).toInt().clamp(0, 100);
    return Container(
      color: context.backgroundColor.withOpacity(0.9),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(40)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: context.w(200),
                height: context.h(200),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: context.w(200),
                      height: context.h(200),
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: context.w(20),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.textColor.withOpacity(0.3),
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    SizedBox(
                      width: context.w(200),
                      height: context.h(200),
                      child: ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.gradient.createShader(bounds),
                        blendMode: BlendMode.srcIn,
                        child: CircularProgressIndicator(
                          value: widget.progress,
                          strokeWidth: context.w(20),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.transparent,
                          ),
                          backgroundColor: Colors.transparent,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ),
                    Text(
                      '$progressPercent%',
                      style: context.appTextStyles?.imageGenerateLoadingPercent,
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.h(32)),
              FadeTransition(
                opacity: _fadeController,
                child: Text(
                  _displayedStage,
                  style: context.appTextStyles?.imageGenerateLoadingStage,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: context.h(40)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStageIndicator(context, 'Preparing', widget.progress >= 0.0),
                  SizedBox(width: context.w(8)),
                  _buildStageConnector(context, widget.progress >= 0.2),
                  SizedBox(width: context.w(8)),
                  _buildStageIndicator(context, 'Rendering', widget.progress >= 0.4),
                  SizedBox(width: context.w(8)),
                  _buildStageConnector(context, widget.progress >= 0.6),
                  SizedBox(width: context.w(8)),
                  _buildStageIndicator(context, 'Finalizing', widget.progress >= 0.8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageIndicator(BuildContext context, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: context.w(12),
          height: context.h(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? context.primaryColor : context.textColor.withOpacity(0.3),
            border: Border.all(
              color: isActive ? context.primaryColor : context.textColor.withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
        SizedBox(height: context.h(4)),
        Text(
          label,
          style: (context.appTextStyles?.imageGenerateStageLabel)?.copyWith(
            color: isActive ? context.primaryColor : context.textColor.withOpacity(0.5),
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
        color: isActive ? context.primaryColor : context.textColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
