import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/loading_overlay.dart';
import 'package:imagifyai/Core/services/generation_limit_service.dart';
import 'package:imagifyai/Core/services/rewarded_ad_service.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:imagifyai/models/wallpaper/wallpaper.dart';
import 'package:imagifyai/view/ImageCreated/widgets/action_buttons_row.dart';
import 'package:imagifyai/view/ImageCreated/widgets/creation_image_preview.dart';
import 'package:imagifyai/view/ImageCreated/widgets/image_created_app_bar.dart';
import 'package:imagifyai/view/ImageCreated/widgets/prompt_editor_card.dart';
import 'package:imagifyai/viewModel/image_created_view_model.dart';
import 'package:provider/provider.dart';

class ImageCreatedScreen extends StatefulWidget {
  const ImageCreatedScreen({super.key});

  @override
  State<ImageCreatedScreen> createState() => _ImageCreatedScreenState();
}

class _ImageCreatedScreenState extends State<ImageCreatedScreen> {
  bool _initialized = false;
  Timer? _pollingTimer;
  StreamController<int>? _elapsedTimeController;
  String? _lastWallpaperId;
  String?
  _lastImageUrl; // Track last image URL to reset retry count on URL change
  late TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    // Defer the setWallpaper call until after the build phase is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Wallpaper) {
          final viewModel = context.read<ImageCreatedViewModel>();
          viewModel.setWallpaper(args);

          // Initialize prompt controller with wallpaper prompt
          _promptController.text = args.prompt.isNotEmpty
              ? args.prompt
              : '3D cartoon-style illustration of a young girl with Día de los Muertos face paint, wearing casual clothes, standing in a glowing.';

          // Track the initial wallpaper ID
          _lastWallpaperId = args.id;

          // Only start polling if image is not ready yet
          if (args.imageUrl.isEmpty || args.imageUrl == 'null') {
            _startPolling(viewModel);
          } else {
            // Image is already ready, stop any polling
            _pollingTimer?.cancel();
            _pollingTimer = null;
            _elapsedTimeController?.close();
            _elapsedTimeController = null;
          }
        }
      }
    });
  }

  void _startPolling(ImageCreatedViewModel viewModel) {
    // Cancel existing timer if any
    _pollingTimer?.cancel();
    _elapsedTimeController?.close();

    // Create stream for elapsed time updates (only updates the elapsed time widget, not entire screen)
    _elapsedTimeController = StreamController<int>.broadcast();
    Timer? elapsedTimer;
    elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !viewModel.isPolling) {
        timer.cancel();
        _elapsedTimeController?.close();
        _elapsedTimeController = null;
        return;
      }
      // Emit elapsed time without rebuilding entire screen
      final elapsed = viewModel.elapsedPollingTime;
      if (_elapsedTimeController != null && !_elapsedTimeController!.isClosed) {
        _elapsedTimeController!.add(elapsed);
      }
    });

    // Poll every 5 seconds to check if image is ready (reduced frequency)
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final currentWallpaper = viewModel.wallpaper;
      if (currentWallpaper != null &&
          (currentWallpaper.imageUrl.isEmpty ||
              currentWallpaper.imageUrl == 'null')) {
        viewModel.checkWallpaperStatus(context);
      } else {
        // Image is ready, stop polling
        timer.cancel();
        _pollingTimer = null;
        elapsedTimer?.cancel();
        _elapsedTimeController?.close();
        _elapsedTimeController = null;
      }
    });
  }

  void _restartPollingIfNeeded(ImageCreatedViewModel viewModel) {
    final currentWallpaper = viewModel.wallpaper;
    if (currentWallpaper == null) return;

    // Check if wallpaper ID changed (e.g., after recreate)
    if (_lastWallpaperId != currentWallpaper.id) {
      _lastWallpaperId = currentWallpaper.id;
      viewModel.clearImageLoadError();

      // If image is not ready, start polling
      if (currentWallpaper.imageUrl.isEmpty ||
          currentWallpaper.imageUrl == 'null') {
        _startPolling(viewModel);
      }
    } else if (viewModel.isPolling &&
        (currentWallpaper.imageUrl.isEmpty ||
            currentWallpaper.imageUrl == 'null')) {
      // Wallpaper ID didn't change but polling should be active
      // Make sure polling is running
      if (_pollingTimer == null || !_pollingTimer!.isActive) {
        _startPolling(viewModel);
      }
    }
  }

  Future<void> _onTryAgainTapped(BuildContext context) async {
    final can = await GenerationLimitService.canGenerate();
    if (!mounted) return;
    final viewModel = context.read<ImageCreatedViewModel>();
    final editedPrompt = _promptController.text.trim();

    Future<void> doRecreate() async {
      await viewModel.recreate(context, editedPrompt: editedPrompt);
      if (mounted && editedPrompt.isNotEmpty) {
        final wp = viewModel.wallpaper;
        if (wp != null && wp.prompt == editedPrompt) {
          _promptController.text = editedPrompt;
        }
      }
    }

    if (can) {
      await doRecreate();
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Daily limit reached',
          style: context.appTextStyles?.imageGenerateSectionTitle,
        ),
        content: Text(
          'You\'ve used your free generations for today. Watch a short ad for 1 more?',
          style: context.appTextStyles?.imageGeneratePromptText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.primaryColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              final shown = await RewardedAdService.showRewardedAd(
                onReward: () {
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  doRecreate();
                },
              );
              if (!dialogContext.mounted) return;
              if (!shown) {
                SnackbarUtil.showTopSnackBar(
                  dialogContext,
                  'Ad not ready. Try again in a moment.',
                  isError: true,
                );
              }
            },
            child: Text(
              'Watch ad',
              style: TextStyle(color: context.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _elapsedTimeController?.close();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageCreatedViewModel>(
      builder: (context, imageCreatedViewModel, _) {
        // Check if we need to restart polling (e.g., after recreate)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _restartPollingIfNeeded(imageCreatedViewModel);
          }
        });

        final wp = imageCreatedViewModel.wallpaper;
        final imageUrl = wp?.imageUrl ?? '';

        // Reset retry count if image URL changed (defer to avoid notifyListeners during build)
        if (imageUrl.isNotEmpty &&
            imageUrl != 'null' &&
            imageUrl != _lastImageUrl) {
          _lastImageUrl = imageUrl;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) imageCreatedViewModel.clearImageLoadError();
          });
        }

        // Ensure isPolling is false if image is available
        if (wp != null &&
            imageUrl.isNotEmpty &&
            imageUrl != 'null' &&
            imageCreatedViewModel.isPolling) {
          // Image is available but isPolling is still true, force update
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              imageCreatedViewModel.setWallpaper(wp);
            }
          });
        }

        // Update prompt controller if wallpaper changes (but preserve user edits during recreation)
        if (wp != null && wp.prompt.isNotEmpty) {
          // Only update if the wallpaper prompt is different and we're not in the middle of recreation
          // This ensures the edited prompt stays visible after recreation
          if (_promptController.text != wp.prompt &&
              !imageCreatedViewModel.isLoading) {
            _promptController.text = wp.prompt;
          }
        }

        return Scaffold(
          backgroundColor: context.backgroundColor,
          appBar: const ImageCreatedAppBar(),
          body: SafeArea(
            child: Stack(
              children: [
                SafeArea(
                  child: ListView(
                    shrinkWrap: true,
                    padding: context.padSym(h: 20),
                    children: [
                      Text(
                        'Your Creation',
                        style: context.appTextStyles?.imageCreatedTitle,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: context.h(20)),
                      Container(
                        height: context.h(410),
                        width: context.w(350),
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          borderRadius: BorderRadius.circular(
                            context.radius(12),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            context.radius(12),
                          ),
                          child: CreationImagePreview(
                            imageUrl: imageUrl,
                            viewModel: imageCreatedViewModel,
                            elapsedTimeStream: _elapsedTimeController?.stream,
                            initialElapsed:
                                imageCreatedViewModel.elapsedPollingTime,
                            isMounted: () => mounted,
                          ),
                        ),
                      ),
                      SizedBox(height: context.h(20)),
                      PromptEditorCard(
                        controller: _promptController,
                        onCopyTap: () {
                          Clipboard.setData(
                            ClipboardData(text: _promptController.text),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Prompt copied to clipboard',
                                style: context
                                    .appTextStyles
                                    ?.imageCreatedPromptText,
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: context.primaryColor,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: context.h(16)),
                      ActionButtonsRow(
                        viewModel: imageCreatedViewModel,
                        onTryAgainTap: () => _onTryAgainTapped(context),
                      ),
                      SizedBox(height: context.h(20)),
                    ],
                  ),
                ),
                if (imageCreatedViewModel.isPolling)
                  Consumer<ImageCreatedViewModel>(
                    builder: (context, vm, _) => LoadingOverlay(
                      progress: vm.creationProgress,
                      currentStage: vm.currentStage,
                      elapsedTime: vm.elapsedPollingTimeFormatted,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
