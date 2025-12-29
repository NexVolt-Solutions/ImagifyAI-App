import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/theme/theme_extensions.dart';
import 'package:genwalls/models/wallpaper/wallpaper.dart';
import 'package:genwalls/viewModel/image_created_view_model.dart';
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
  bool _imageLoadError = false;
  String? _errorMessage;
  int _retryCount = 0;
  String? _lastWallpaperId;
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
          
          // Start polling for image status
          _startPolling(viewModel);
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
          (currentWallpaper.imageUrl.isEmpty || currentWallpaper.imageUrl == 'null')) {
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
      
      // Reset error state for new wallpaper
      _imageLoadError = false;
      _errorMessage = null;
      _retryCount = 0; // Reset retry count for new wallpaper
      
      // If image is not ready, start polling
      if (currentWallpaper.imageUrl.isEmpty || currentWallpaper.imageUrl == 'null') {
        if (kDebugMode) {
          print('🔄 Wallpaper ID changed, restarting polling for new wallpaper: ${currentWallpaper.id}');
        }
        _startPolling(viewModel);
      }
    } else if (viewModel.isPolling && 
               (currentWallpaper.imageUrl.isEmpty || currentWallpaper.imageUrl == 'null')) {
      // Wallpaper ID didn't change but polling should be active
      // Make sure polling is running
      if (_pollingTimer == null || !_pollingTimer!.isActive) {
        if (kDebugMode) {
          print('🔄 Polling should be active but timer not running, restarting...');
        }
        _startPolling(viewModel);
      }
    }
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
        
        // Update prompt controller if wallpaper changes
        if (wp != null && wp.prompt.isNotEmpty && _promptController.text != wp.prompt) {
          _promptController.text = wp.prompt;
        }

        return Scaffold(
          backgroundColor: context.backgroundColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Container(
              color: context.backgroundColor,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                  Positioned(
                    child: SvgPicture.asset(AppAssets.starLogo, fit: BoxFit.cover),
                  ),
                  SvgPicture.asset(AppAssets.genWallsLogo, fit: BoxFit.cover),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: ListView(
              shrinkWrap: true,
              padding: context.padSym(h: 20),
              children: [
                Text(
                  "Your Creation",
                  style: context.appTextStyles?.imageCreatedTitle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.h(20)),
                Container(
                  height: context.h(410),
                  width: context.w(350),
                  decoration: BoxDecoration(
                    color: context.backgroundColor,
                    borderRadius: BorderRadius.circular(context.radius(12)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(context.radius(12)),
                    child: imageUrl.isNotEmpty && imageUrl != 'null'
                        ? (_imageLoadError
                            ? Container(
                                color: context.backgroundColor,
                                child: Center(
                                  child: Container(
                                    padding: context.padAll(15),
                                    decoration: BoxDecoration(
                                      color: context.backgroundColor.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(context.radius(8)),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _errorMessage?.contains('403') == true 
                                              ? Icons.lock_outline 
                                              : Icons.error_outline,
                                          color: _errorMessage?.contains('403') == true 
                                              ? Colors.orange 
                                              : Colors.red,
                                          size: 32,
                                        ),
                                        SizedBox(height: context.h(10)),
                                        Text(
                                          _errorMessage ?? 'Failed to load image',
                                          style: context.appTextStyles?.imageCreatedError,
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: context.h(10)),
                                        CustomButton(
                                          onPressed: () {
                                            setState(() {
                                              _imageLoadError = false;
                                              _errorMessage = null;
                                              _retryCount++; // Increment to force image reload
                                            });
                                          },
                                          height: context.h(36),
                                          width: context.w(120),
                                          gradient: AppColors.gradient,
                                          text: 'Try Again',                                      
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.fill,
                                // Force reload on retry by changing the key
                                key: ValueKey('${imageUrl}_retry_$_retryCount'),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: context.primaryColor,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              // Extract error information
                              String errorMsg = 'Failed to load image';
                              
                              if (error.toString().contains('403') || 
                                  error.toString().contains('Forbidden')) {
                                errorMsg = 'Image access denied (403)\nS3 bucket permissions issue';
                              } else if (error.toString().contains('404')) {
                                errorMsg = 'Image not found (404)';
                              } else if (error.toString().contains('timeout') || 
                                         error.toString().contains('TimeoutException')) {
                                errorMsg = 'Connection timeout\nPlease check your internet';
                              } else if (error.toString().contains('SocketException') ||
                                         error.toString().contains('Connection reset') ||
                                         error.toString().contains('Connection closed')) {
                                errorMsg = 'Connection error\nPlease check your internet';
                              } else if (error.toString().contains('HttpException')) {
                                errorMsg = 'Network error\nPlease try again';
                              }
                              
                              if (kDebugMode) {
                                print('❌ Error loading image: $error');
                                print('Image URL: $imageUrl');
                                print('Error type: ${error.runtimeType}');
                              }
                              
                              // Update state for retry functionality
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() {
                                    _imageLoadError = true;
                                    _errorMessage = errorMsg;
                                  });
                                  
                                  // Auto-retry for network errors (up to 3 times)
                                  if ((error.toString().contains('SocketException') ||
                                       error.toString().contains('HttpException') ||
                                       error.toString().contains('Connection') ||
                                       error.toString().contains('timeout')) &&
                                      _retryCount < 3) {
                                    Future.delayed(const Duration(seconds: 2), () {
                                      if (mounted) {
                                        setState(() {
                                          _imageLoadError = false;
                                          _errorMessage = null;
                                          _retryCount++;
                                        });
                                      }
                                    });
                                  }
                                }
                              });
                              
                              // Return a placeholder that will be replaced by the error state
                              return const SizedBox.shrink();
                            },
                          ))
                        : Container(
                            color: context.backgroundColor,
                            child: imageCreatedViewModel.isPolling
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          color: context.primaryColor,
                                        ),
                                        SizedBox(height: context.h(10)),
                                        Text(
                                          'Crafting Your Masterpiece...',
                                          style: context.appTextStyles?.imageCreatedPollingTitle,
                                        ),
                                        SizedBox(height: context.h(5)),
                                        StreamBuilder<int>(
                                          stream: _elapsedTimeController?.stream,
                                          initialData: imageCreatedViewModel.elapsedPollingTime,
                                          builder: (context, snapshot) {
                                            final elapsed = snapshot.data ?? 0;
                                            String formatted;
                                            if (elapsed < 60) {
                                              formatted = '${elapsed}s';
                                            } else {
                                              final minutes = elapsed ~/ 60;
                                              final seconds = elapsed % 60;
                                              formatted = '${minutes}m ${seconds}s';
                                            }
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
                                  )
                                : const SizedBox.shrink(),
                          ),
                  ),
                ),
                SizedBox(height: context.h(20)),
                Container(
                  padding: context.padAll(20),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(context.radius(12)),
                  ),
                  child: Stack(
                    children: [
                      TextFormField(
                        controller: _promptController,
                        maxLines: 4,
                        minLines: 1,
                        enabled: true,
                        readOnly: false,
                        style: context.appTextStyles?.imageCreatedPromptText,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your prompt...',
                          hintStyle: context.appTextStyles?.imageCreatedPromptHint,
                          contentPadding: EdgeInsets.only(
                            bottom: context.h(30),
                            right: context.w(40),
                            left: context.w(10),
                            top: context.h(10),
                          ),
                        ),
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                      ),
                      Positioned(
                        bottom: context.h(10),
                        right: context.w(10),
                        child: GestureDetector(
                          onTap: () {
                            // Copy prompt to clipboard
                            Clipboard.setData(ClipboardData(text: _promptController.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Prompt copied to clipboard',
                                  style: context.appTextStyles?.imageCreatedPromptText,
                                ),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: context.primaryColor,
                                ),
                              );
                            },
                            child: Icon(Icons.copy, color: context.textColor, size: 20),
                          ),
                        ),
                      ],
                    ),
                ),
                SizedBox(height: context.h(16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                      onPressed: imageCreatedViewModel.isLoading
                          ? null
                          : () => imageCreatedViewModel.recreate(context),
                       
                      width: context.w(165),
                      iconHeight: 24,
                      iconWidth: 24,
                      gradient: AppColors.gradient,
                      text: imageCreatedViewModel.isLoading ? 'Regenerating...' : 'Try Again',
                      icon: AppAssets.reCreateIcon,
                    ),
                    CustomButton(
                      onPressed: imageCreatedViewModel.isDownloading
                          ? null
                          : () => imageCreatedViewModel.showDownloadDialog(context),
                       
                      width: context.w(165),
                      iconHeight: 24,
                      iconWidth: 24,
                      gradient: AppColors.gradient,
                      text: imageCreatedViewModel.isDownloading
                          ? 'Preparing...'
                          : 'Get Wallpaper',
                      icon: AppAssets.downloadIcon,
                    ),
                  ],
                ),
                SizedBox(height: context.h(20)),
              ],
            ),
          ),
        );
      },
    );
  }
}
