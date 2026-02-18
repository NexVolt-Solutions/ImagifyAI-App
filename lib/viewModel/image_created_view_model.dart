import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/Core/services/analytics_service.dart';
import 'package:imagifyai/Core/services/in_app_review_service.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:imagifyai/models/wallpaper/wallpaper.dart';
import 'package:imagifyai/repositories/wallpaper_repository.dart';
import 'package:imagifyai/viewModel/sign_in_view_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class ImageCreatedViewModel extends ChangeNotifier {
  ImageCreatedViewModel({WallpaperRepository? wallpaperRepository})
    : _wallpaperRepository = wallpaperRepository ?? WallpaperRepository();

  final WallpaperRepository _wallpaperRepository;

  Wallpaper? wallpaper;
  bool isLoading = false;
  bool isDownloading = false;
  bool isPolling = false;
  String? errorMessage;
  DateTime? _pollingStartTime;
  int _pollingAttempts = 0;
  static const int _maxPollingAttempts =
      120; // 10 minutes max (120 attempts * 5 seconds)

  // Progress tracking for overlay
  double creationProgress = 0.0;
  Timer? _progressTimer;
  String _currentStage = 'Preparing prompt...';
  String get currentStage => _currentStage;

  void setWallpaper(Wallpaper? data) {
    wallpaper = data;

    // If wallpaper already has an image URL, stop polling
    if (data != null && data.imageUrl.isNotEmpty && data.imageUrl != 'null') {
      isPolling = false;
      _stopProgressAnimation();
      creationProgress = 1.0;
      _currentStage = 'Complete!';
      _pollingStartTime = null;
      _pollingAttempts = 0;

      if (kDebugMode) {
        print('✅ Wallpaper already has image URL, skipping polling');
        print('Image URL: ${data.imageUrl}');
      }
    } else if (data != null) {
      // Image not ready yet, will start polling
      isPolling = true;
      if (kDebugMode) {
        print('⏳ Wallpaper image not ready yet, will start polling');
        print('Wallpaper ID: ${data.id}');
      }
    }

    notifyListeners();
  }

  Future<void> checkWallpaperStatus(BuildContext context) async {
    if (wallpaper == null || wallpaper!.id.isEmpty) return;

    // If image is already available, stop polling
    if (wallpaper!.imageUrl.isNotEmpty && wallpaper!.imageUrl != 'null') {
      isPolling = false;
      _stopProgressAnimation();
      creationProgress = 1.0;
      _currentStage = 'Complete!';
      _pollingStartTime = null;
      _pollingAttempts = 0;
      notifyListeners();
      return;
    }

    // Initialize polling start time on first attempt
    if (_pollingStartTime == null) {
      _pollingStartTime = DateTime.now();
      // Start progress animation when polling begins
      _startProgressAnimation();
    }

    // Check timeout (10 minutes max)
    if (_pollingAttempts >= _maxPollingAttempts) {
      isPolling = false;
      _stopProgressAnimation();
      errorMessage =
          'Your masterpiece is taking a bit longer than usual. Feel free to try again!';
      if (kDebugMode) {
        print('⏱️ Polling timeout after $_pollingAttempts attempts');
      }
      _showMessage(context, errorMessage!);
      notifyListeners();
      return;
    }

    _pollingAttempts++;
    isPolling = true;
    notifyListeners();

    // Get access token
    final signInViewModel = context.read<SignInViewModel>();
    final accessToken = signInViewModel.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      isPolling = false;
      notifyListeners();
      return;
    }

    try {
      final updatedWallpaper = await _wallpaperRepository.getWallpaperById(
        wallpaperId: wallpaper!.id,
        accessToken: accessToken,
      );

      if (updatedWallpaper != null) {
        if (updatedWallpaper.imageUrl.isNotEmpty &&
            updatedWallpaper.imageUrl != 'null') {
          // Image is ready!
          // Preserve the edited prompt from current wallpaper (if it was edited)
          // The API might return the old prompt, so we keep the one from the current wallpaper
          final preservedPrompt = wallpaper!.prompt;

          wallpaper = Wallpaper(
            id: updatedWallpaper.id,
            prompt: preservedPrompt, // Preserve the edited prompt
            size: updatedWallpaper.size,
            style: updatedWallpaper.style,
            title: updatedWallpaper.title,
            aiModel: updatedWallpaper.aiModel,
            thumbnailUrl: updatedWallpaper.thumbnailUrl,
            imageUrl: updatedWallpaper.imageUrl, // Use the new image URL
            createdAt: updatedWallpaper.createdAt,
          );

          isPolling = false;
          _stopProgressAnimation();
          creationProgress = 1.0;
          _currentStage = 'Complete!';
          _pollingStartTime = null;
          _pollingAttempts = 0;

          final elapsedTime = _pollingStartTime != null
              ? DateTime.now().difference(_pollingStartTime!).inSeconds
              : 0;

          if (kDebugMode) {
            print('✅ Image is ready! URL: ${updatedWallpaper.imageUrl}');
            print(
              '⏱️ Total generation time: ${elapsedTime}s (${_pollingAttempts} polling attempts)',
            );
            print('📝 Preserved prompt: $preservedPrompt');
          }

          notifyListeners();
        } else {
          // Still generating, keep polling
          final elapsedTime = _pollingStartTime != null
              ? DateTime.now().difference(_pollingStartTime!).inSeconds
              : 0;

          if (kDebugMode && _pollingAttempts % 12 == 0) {
            // Log every minute (12 attempts * 5 seconds)
            print(
              '⏳ Still generating... Elapsed: ${elapsedTime}s, Attempts: $_pollingAttempts',
            );
          }

          isPolling = true;
          notifyListeners();
        }
      } else {
        // Wallpaper not found, keep polling
        isPolling = true;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking wallpaper status: $e');
      }
      // Don't stop polling on error, just log it
      isPolling = true;
      notifyListeners();
    }
  }

  void _startProgressAnimation() {
    _progressTimer?.cancel();
    creationProgress = 0.0;
    _currentStage = 'Generating your masterpiece...';

    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!isPolling) {
        timer.cancel();
        return;
      }

      // Simple progress animation from 0 to 99%
      // Will reach 100% only when image is ready
      if (creationProgress < 0.99) {
        creationProgress += 0.01; // Increase by 1% every 50ms
      } else {
        creationProgress = 0.99; // Cap at 99% until image is ready
      }

      notifyListeners();
    });
  }

  void _stopProgressAnimation() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  // Get elapsed time in seconds
  int get elapsedPollingTime {
    if (_pollingStartTime == null) return 0;
    return DateTime.now().difference(_pollingStartTime!).inSeconds;
  }

  // Get elapsed time as formatted string (e.g., "2m 30s")
  String get elapsedPollingTimeFormatted {
    final seconds = elapsedPollingTime;
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  Future<void> recreate(BuildContext context, {String? editedPrompt}) async {
    if (isLoading || wallpaper == null || wallpaper!.id.isEmpty) return;

    // Get access token from SignInViewModel
    final signInViewModel = context.read<SignInViewModel>();
    final accessToken = signInViewModel.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      _showMessage(context, 'Sign in to regenerate your wallpaper');
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final oldWallpaperId = wallpaper!.id;

      // Use edited prompt if provided, otherwise use original prompt
      // Always use the same size and style from the original wallpaper
      final promptToUse = editedPrompt?.trim() ?? wallpaper!.prompt;
      final sizeToUse = wallpaper!.size;
      final styleToUse = wallpaper!.style;

      if (kDebugMode) {
        print('🔄 Recreating wallpaper with:');
        print('   Prompt: $promptToUse');
        print('   Size: $sizeToUse');
        print('   Style: $styleToUse');
      }

      final recreatedWallpaper = await _wallpaperRepository.recreateWallpaper(
        wallpaperId: oldWallpaperId,
        accessToken: accessToken,
        prompt: promptToUse,
        size: sizeToUse,
        style: styleToUse,
      );

      // Check if API returned a different prompt than what we sent
      if (kDebugMode && recreatedWallpaper.prompt != promptToUse) {
        print('⚠️ WARNING: API returned different prompt!');
        print('   Sent prompt: "$promptToUse"');
        print('   API returned: "${recreatedWallpaper.prompt}"');
        print(
          '   This indicates the backend is not using the prompt from the request body.',
        );
        print(
          '   The generated image will be based on the old prompt, not the edited one.',
        );
      }

      // Update the wallpaper with the edited prompt if it was provided
      // (API might not return the updated prompt, so we override it)
      wallpaper = Wallpaper(
        id: recreatedWallpaper.id,
        prompt: promptToUse, // Use the edited prompt (not the API response)
        size: recreatedWallpaper.size,
        style: recreatedWallpaper.style,
        title: recreatedWallpaper.title,
        aiModel: recreatedWallpaper.aiModel,
        thumbnailUrl: recreatedWallpaper.thumbnailUrl,
        imageUrl: recreatedWallpaper.imageUrl,
        createdAt: recreatedWallpaper.createdAt,
      );

      // Reset polling state and start checking for the new image
      isPolling = true;
      _pollingStartTime =
          DateTime.now(); // Reset polling start time for new generation
      _pollingAttempts = 0; // Reset polling attempts counter

      // Start progress animation
      _startProgressAnimation();

      if (kDebugMode) {
        print('✅ Wallpaper recreated with new ID: ${wallpaper!.id}');
        print('New prompt: ${wallpaper!.prompt}');
        print('New image URL: ${wallpaper!.imageUrl}');
      }

      _showMessage(
        context,
        'New version is being created! This may take a moment...',
        isError: false,
      );

      // Start checking status immediately
      if (wallpaper!.imageUrl.isEmpty || wallpaper!.imageUrl == 'null') {
        // Image is still generating, will be polled by the screen
        if (kDebugMode) {
          print(
            '⏳ New wallpaper image is still generating, polling will start...',
          );
        }
      }

      notifyListeners();
    } on ApiException catch (e) {
      errorMessage = e.message;
      isPolling = false;
      _showMessage(context, e.message);
      notifyListeners();
    } catch (_) {
      errorMessage =
          'Hmm, something unexpected happened. Let\'s try that again!';
      isPolling = false;
      _showMessage(context, errorMessage!);
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> showDownloadDialog(BuildContext context) async {
    if (wallpaper == null || wallpaper!.id.isEmpty) return;

    // Get access token from SignInViewModel
    final signInViewModel = context.read<SignInViewModel>();
    final accessToken = signInViewModel.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      _showMessage(context, 'Sign in to save your masterpiece');
      return;
    }

    // Show dialog with Download and Share options
    final imageUrl = wallpaper!.imageUrl;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return _DownloadShareDialog(
          imageUrl: imageUrl,
          onDownload: () async {
            Navigator.pop(dialogContext);
            await _downloadImage(context);
          },
          onShare: () async {
            Navigator.pop(dialogContext);
            await _shareWallpaper(context);
          },
        );
      },
    );
  }

  Future<void> _downloadImage(BuildContext context) async {
    if (isDownloading || wallpaper == null || wallpaper!.id.isEmpty) return;

    // Get access token from SignInViewModel
    final signInViewModel = context.read<SignInViewModel>();
    final accessToken = signInViewModel.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      _showMessage(context, 'Sign in to save your masterpiece');
      return;
    }

    isDownloading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Get wallpaper data from download API
      final wallpaperData = await _wallpaperRepository.downloadWallpaper(
        wallpaperId: wallpaper!.id,
        accessToken: accessToken,
      );

      // Download the actual image from the URL
      final imageUrl = wallpaperData.imageUrl;
      if (imageUrl.isEmpty || imageUrl == 'null') {
        throw Exception('Image URL not available');
      }

      // Download image bytes from URL
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to download image: ${response.statusCode}');
      }

      // Save image to device
      await _saveImageToDevice(context, response.bodyBytes, wallpaper!.id);

      _showMessage(
        context,
        'Saved to your device! Enjoy your new wallpaper',
        isError: false,
      );
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (e) {
      errorMessage =
          'Couldn\'t save your wallpaper right now. Let\'s try again!';
      _showMessage(context, errorMessage!);
    } finally {
      isDownloading = false;
      notifyListeners();
    }
  }

  Future<void> _shareWallpaper(BuildContext context) async {
    if (wallpaper == null || wallpaper!.id.isEmpty) {
      _showMessage(context, 'Wallpaper is not available right now');
      return;
    }

    // Get access token from SignInViewModel
    final signInViewModel = context.read<SignInViewModel>();
    final accessToken = signInViewModel.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      _showMessage(context, 'Sign in to share your creation');
      return;
    }

    try {
      // Get wallpaper data from download API
      final wallpaperData = await _wallpaperRepository.downloadWallpaper(
        wallpaperId: wallpaper!.id,
        accessToken: accessToken,
      );

      final imageUrl = wallpaperData.imageUrl;
      if (imageUrl.isEmpty || imageUrl == 'null') {
        _showMessage(
          context,
          'Image is not ready yet. Please try again in a moment',
        );
        return;
      }

      // Download the image to a temporary file
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to download image: ${response.statusCode}');
      }

      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final extension = imageUrl.contains('.')
          ? imageUrl.split('.').last.split('?').first
          : 'jpg';
      final fileName =
          'wallpaper_share_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Share the image file
      final xFile = XFile(filePath);
      await Share.shareXFiles(
        [xFile],
        text: 'Check out this amazing wallpaper!',
        subject: 'Wallpaper from imagifyai',
      );

      InAppReviewService.recordShareAndMaybeReview(context);
      AnalyticsService.logImageShared();

      // Clean up temporary file after a delay
      Future.delayed(const Duration(seconds: 5), () {
        if (file.existsSync()) {
          file.deleteSync();
        }
      });
    } on ApiException catch (e) {
      _showMessage(context, e.message);
    } catch (e) {
      _showMessage(context, 'Couldn\'t share right now. Give it another try!');
    }
  }

  // Keep old method for backward compatibility
  Future<void> download(BuildContext context) async {
    await showDownloadDialog(context);
  }

  Future<void> _saveImageToDevice(
    BuildContext context,
    Uint8List imageBytes,
    String wallpaperId,
  ) async {
    try {
      // Get the directory for saving images
      final directory = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${directory.path}/imagifyai/Wallpapers');

      // Create directory if it doesn't exist
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      final imageUrl = wallpaper!.imageUrl;
      final extension = imageUrl.isNotEmpty && imageUrl.contains('.')
          ? imageUrl.split('.').last
          : 'jpg';
      final fileName =
          'wallpaper_${wallpaperId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final filePath = '${imageDir.path}/$fileName';

      // Write image bytes to file
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);
    } catch (e) {
      throw Exception('Failed to save image: ${e.toString()}');
    }
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    SnackbarUtil.showTopSnackBar(context, message, isError: isError);
  }
}

// Dialog widget for Download and Share options
class _DownloadShareDialog extends StatelessWidget {
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final String imageUrl;

  const _DownloadShareDialog({
    required this.onDownload,
    required this.onShare,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: AppColors.blackColor,
        child: SafeArea(
          child: Padding(
            padding: context.padAll(20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: context.h(20)),
                // Display the generated image preview - Full screen
                Expanded(
                  child: imageUrl.isNotEmpty && imageUrl != 'null'
                      ? Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(
                              context.radius(12),
                            ),
                            border: Border.all(
                              color: context.primaryColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              context.radius(12),
                            ),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: AppLoadingIndicator.medium(
                                        color: context.primaryColor,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.black,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                        SizedBox(height: context.h(8)),
                                        Text(
                                          'Couldn\'t load image. Please try again',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white70,
                                            fontSize: context.text(12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(
                              context.radius(12),
                            ),
                          ),
                          child: Center(
                            child: AppLoadingIndicator.medium(
                              color: context.primaryColor,
                            ),
                          ),
                        ),
                ),
                SizedBox(height: context.h(20)),
                Text(
                  'What would you like to do?',
                  style: GoogleFonts.poppins(
                    color: AppColors.whiteColor,
                    fontSize: context.text(16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: context.h(16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: context.h(60),
                            width: context.w(60),
                            decoration: BoxDecoration(
                              color: context.primaryColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.download,
                                color: context.primaryColor,
                                size: 30,
                              ),
                              onPressed: onDownload,
                            ),
                          ),
                          SizedBox(height: context.h(8)),
                          Text(
                            'Save to Device',
                            style: GoogleFonts.poppins(
                              color: AppColors.whiteColor,
                              fontSize: context.text(14),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: context.w(20)),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: context.h(60),
                            width: context.w(60),
                            decoration: BoxDecoration(
                              color: context.primaryColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.share,
                                color: context.primaryColor,
                                size: 30,
                              ),
                              onPressed: onShare,
                            ),
                          ),
                          SizedBox(height: context.h(8)),
                          Text(
                            'Share with Friends',
                            style: GoogleFonts.poppins(
                              color: AppColors.whiteColor,
                              fontSize: context.text(14),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
