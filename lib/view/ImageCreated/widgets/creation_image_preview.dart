import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';
import 'package:imagifyai/Core/CustomWidget/custom_button.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/image_created_view_model.dart';

class CreationImagePreview extends StatelessWidget {
  const CreationImagePreview({
    super.key,
    required this.imageUrl,
    required this.viewModel,
    required this.elapsedTimeStream,
    required this.initialElapsed,
    this.isMounted,
  });

  final String imageUrl;
  final ImageCreatedViewModel viewModel;
  final Stream<int>? elapsedTimeStream;
  final int initialElapsed;
  final bool Function()? isMounted;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isPolling) {
      return _buildPollingState(context);
    }
    if (imageUrl.isEmpty || imageUrl == 'null') {
      return _buildNoImage(context);
    }
    if (viewModel.imageLoadError && viewModel.imageRetryCount >= 3) {
      return _buildErrorState(context);
    }
    return _buildImage(context);
  }

  Widget _buildErrorState(BuildContext context) {
    final is403 = viewModel.imageLoadErrorMessage?.contains('403') == true;
    return Container(
      color: context.backgroundColor,
      child: Center(
        child: Container(
          padding: context.padAll(15),
          decoration: BoxDecoration(
            color: context.backgroundColor.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(context.radius(8)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                is403 ? Icons.lock_outline : Icons.error_outline,
                color: is403 ? Colors.orange : Colors.red,
                size: 32,
              ),
              SizedBox(height: context.h(10)),
              Text(
                viewModel.imageLoadErrorMessage ?? 'Failed to load image',
                style: context.appTextStyles?.imageCreatedError,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.h(10)),
              CustomButton(
                onPressed: () => viewModel.clearImageLoadError(),
                height: context.h(36),
                width: context.w(120),
                gradient: AppColors.gradient,
                text: 'Try Again',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final retryUrl = viewModel.imageRetryCount > 0 && viewModel.imageRetryTimestamp > 0
        ? '$imageUrl?retry=${viewModel.imageRetryCount}&t=${viewModel.imageRetryTimestamp}'
        : imageUrl;
    return Image.network(
      retryUrl,
      fit: BoxFit.fill,
      key: ValueKey('${imageUrl}_retry_${viewModel.imageRetryCount}'),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: AppLoadingIndicator.medium(color: context.primaryColor),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        final errorMsg = _parseImageError(error.toString());
        final isNetworkError = _isNetworkError(error.toString());

        if (isNetworkError && viewModel.imageRetryCount < 3) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (isMounted?.call() ?? true) {
              Future.delayed(const Duration(seconds: 2), () {
                if (isMounted?.call() ?? true) {
                  if (viewModel.imageRetryCount < 3) {
                    viewModel.incrementImageRetry();
                  }
                }
              });
            }
          });
          return Container(
            color: context.backgroundColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppLoadingIndicator.medium(color: context.primaryColor),
                  SizedBox(height: context.h(10)),
                  Text(
                    'Retrying... (${viewModel.imageRetryCount + 1}/3)',
                    style: context.appTextStyles?.imageCreatedPollingSubtitle,
                  ),
                ],
              ),
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isMounted?.call() ?? true) {
            viewModel.setImageLoadError(errorMsg);
          }
        });
        return Container(
          color: context.backgroundColor,
          child: Center(
            child: AppLoadingIndicator.medium(color: context.primaryColor),
          ),
        );
      },
    );
  }

  Widget _buildPollingState(BuildContext context) {
    return Container(
      color: context.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLoadingIndicator.medium(color: context.primaryColor),
            SizedBox(height: context.h(10)),
            Text(
              'Crafting Your Masterpiece...',
              style: context.appTextStyles?.imageCreatedPollingTitle,
            ),
            SizedBox(height: context.h(5)),
            StreamBuilder<int>(
              stream: elapsedTimeStream,
              initialData: initialElapsed,
              builder: (context, snapshot) {
                final elapsed = snapshot.data ?? 0;
                final formatted = elapsed < 60
                    ? '${elapsed}s'
                    : '${elapsed ~/ 60}m ${elapsed % 60}s';
                return Text(
                  'Time elapsed: $formatted',
                  style: context.appTextStyles?.imageCreatedPollingTime,
                );
              },
            ),
            SizedBox(height: context.h(5)),
            Text(
              'Great art takes time',
              style: context.appTextStyles?.imageCreatedPollingSubtitle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoImage(BuildContext context) {
    return Container(
      color: context.backgroundColor,
      child: Center(
        child: Text(
          'No image available',
          style: context.appTextStyles?.imageCreatedError,
        ),
      ),
    );
  }

  static String _parseImageError(String errorStr) {
    if (errorStr.contains('403') || errorStr.contains('Forbidden')) {
      return 'Image access denied (403)\nS3 bucket permissions issue';
    }
    if (errorStr.contains('404')) return 'Image not found (404)';
    if (errorStr.contains('timeout') || errorStr.contains('TimeoutException')) {
      return 'Connection timeout\nPlease check your internet';
    }
    if (errorStr.contains('SocketException') ||
        errorStr.contains('Connection reset') ||
        errorStr.contains('Connection closed') ||
        errorStr.contains('HttpException')) {
      return 'Connection error\nPlease check your internet';
    }
    return 'Failed to load image';
  }

  static bool _isNetworkError(String errorStr) {
    return errorStr.contains('timeout') ||
        errorStr.contains('TimeoutException') ||
        errorStr.contains('SocketException') ||
        errorStr.contains('Connection reset') ||
        errorStr.contains('Connection closed') ||
        errorStr.contains('HttpException');
  }
}
