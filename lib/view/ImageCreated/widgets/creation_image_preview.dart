import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/app_cached_network_image.dart';
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
    if (viewModel.imageLoadError) {
      return _buildErrorState(context);
    }
    return _buildImage(context);
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      color: context.backgroundColor,
      child: Center(
        child: Padding(
          padding: context.padAll(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.broken_image_outlined,
                size: 40,
                color: context.primaryColor,
              ),
              SizedBox(height: context.h(10)),
              Text(
                viewModel.imageLoadErrorMessage ?? 'Could not load image',
                style: context.appTextStyles?.imageCreatedError,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.h(10)),
              CustomButton(
                onPressed: () => viewModel.clearImageLoadError(),
                height: context.h(36),
                width: context.w(120),
                gradient: AppColors.gradient,
                text: 'Try again',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      httpHeaders: kWallpaperImageHeaders,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      width: double.infinity,
      height: double.infinity,
      filterQuality: FilterQuality.high,
      fadeInDuration: Duration.zero,
      placeholder: (_, __) => Center(
        child: AppLoadingIndicator.medium(color: context.primaryColor),
      ),
      errorWidget: (context, url, error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isMounted?.call() ?? true) {
            viewModel.setImageLoadError('Could not load image');
          }
        });
        return Center(
          child: AppLoadingIndicator.medium(color: context.primaryColor),
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
}
