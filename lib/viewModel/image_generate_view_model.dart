import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/Core/services/in_app_review_service.dart';
import 'package:imagifyai/Core/utils/Routes/routes_name.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:imagifyai/models/wallpaper/wallpaper.dart';
import 'package:imagifyai/repositories/wallpaper_repository.dart';
import 'package:imagifyai/viewModel/sign_in_view_model.dart';
import 'package:provider/provider.dart';

class ImageGenerateViewModel extends ChangeNotifier {
  ImageGenerateViewModel({WallpaperRepository? wallpaperRepository})
    : _wallpaperRepository = wallpaperRepository ?? WallpaperRepository();

  final WallpaperRepository _wallpaperRepository;

  int selectedIndex = -1;
  int selectedStyleIndex = -1;
  int selectedPromptIndex = -1;
  bool isCreating = false;
  double creationProgress = 0.0;
  Timer? _progressTimer;
  Timer? _pollingTimer;
  String? errorMessage;
  Wallpaper? createdWallpaper;

  // Progress stages
  String _currentStage = 'Preparing prompt...';
  String get currentStage => _currentStage;

  // Polling state
  bool _isPolling = false;
  int _pollingAttempts = 0;
  DateTime? _pollingStartTime;
  static const int _maxPollingAttempts = 120;

  int get elapsedPollingTime {
    if (_pollingStartTime == null) return 0;
    return DateTime.now().difference(_pollingStartTime!).inSeconds;
  }

  String get elapsedPollingTimeFormatted {
    final seconds = elapsedPollingTime;
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  final promptController = TextEditingController();

  final List<Map<String, dynamic>> sizes = [
    {'text1': '1:1', 'text2': 'Square'},
    {'text1': '2:3 Portrait', 'text2': 'Portrait'},
    {'text1': '2:3 Landscape', 'text2': 'Landscape'},
  ];

  Map<String, String> _stylesMap = {};
  List<String> get styles => _stylesMap.keys.toList();
  bool isLoadingStyles = false;
  String? stylesError;

  String get selectedSize {
    if (selectedIndex >= 0 && selectedIndex < sizes.length) {
      return sizes[selectedIndex]['text1'] as String;
    }
    return '1:1';
  }

  String get selectedStyle {
    if (selectedStyleIndex >= 0 && selectedStyleIndex < styles.length) {
      return styles[selectedStyleIndex];
    }
    return 'default';
  }

  void setPromptText(String text) {
    promptController.text = text;
    notifyListeners();
  }

  void setPromptWithDefaults(
    String promptText,
    String styleName,
    int promptIndex,
  ) {
    promptController.text = promptText;
    selectedIndex = 0;
    final styleIndex = styles.indexOf(styleName);
    selectedStyleIndex = styleIndex >= 0 ? styleIndex : -1;
    selectedPromptIndex = promptIndex;
    notifyListeners();
  }

  int? getStyleIndexByName(String styleName) {
    final index = styles.indexOf(styleName);
    return index >= 0 ? index : null;
  }

  void setSelectedSize(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void setSelectedStyle(int index, [BuildContext? context]) {
    selectedStyleIndex = index == selectedStyleIndex ? -1 : index;
    if (selectedStyleIndex >= 0 && selectedStyleIndex < styles.length) {
      InAppReviewService.recordStyleTriedAndMaybeReview(
        styles[selectedStyleIndex],
        context,
      );
    }
    notifyListeners();
  }

  bool isGettingSuggestion = false;

  Future<void> loadStyles(BuildContext context) async {
    if (isLoadingStyles || _stylesMap.isNotEmpty) return;

    final signInViewModel = context.read<SignInViewModel>();
    final accessToken = signInViewModel.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      if (kDebugMode) {
        print('⚠️  No access token available for loading styles');
      }
      return;
    }

    isLoadingStyles = true;
    stylesError = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════════');
        print('=== LOAD STYLES: START ===');
        print('═══════════════════════════════════════════════════════════');
      }

      _stylesMap = await _wallpaperRepository.fetchStyles(
        accessToken: accessToken,
      );

      if (kDebugMode) {
        print('✅ Styles loaded successfully');
        print('Total styles: ${_stylesMap.length}');
        print('Style names: ${styles}');
        print('═══════════════════════════════════════════════════════════');
        print('=== LOAD STYLES: SUCCESS ===');
        print('═══════════════════════════════════════════════════════════');
      }
    } on ApiException catch (e) {
      stylesError = e.message;
      if (kDebugMode) {
        print('❌ Error loading styles: ${e.message}');
      }
    } catch (e) {
      stylesError = 'Failed to load styles';
      if (kDebugMode) {
        print('❌ Unexpected error loading styles: $e');
      }
    } finally {
      isLoadingStyles = false;
      notifyListeners();
    }
  }

  Future<void> getSuggestion(BuildContext context) async {
    final currentPrompt = promptController.text.trim();

    if (currentPrompt.isEmpty) {
      _showMessage(context, 'Start by describing your vision!');
      return;
    }

    final signInViewModel = context.read<SignInViewModel>();
    final accessToken = signInViewModel.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      _showMessage(context, 'Sign in to unlock AI suggestions');
      return;
    }

    isGettingSuggestion = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════════');
        print('=== GET PROMPT SUGGESTION: START ===');
        print('═══════════════════════════════════════════════════════════');
        print('Current prompt: $currentPrompt');
      }

      final response = await _wallpaperRepository.suggestPrompt(
        prompt: currentPrompt,
        accessToken: accessToken,
      );

      if (response.suggestion != null && response.suggestion!.isNotEmpty) {
        promptController.text = response.suggestion!;
        notifyListeners();

        if (kDebugMode) {
          print('✅ Suggestion received: ${response.suggestion}');
          print('═══════════════════════════════════════════════════════════');
          print('=== GET PROMPT SUGGESTION: SUCCESS ===');
          print('═══════════════════════════════════════════════════════════');
        }

        _showMessage(
          context,
          'AI suggestion ready! Check it out above',
          isError: false,
        );
      } else {
        _showMessage(context, 'No suggestion available');
      }
    } on ApiException catch (e) {
      errorMessage = e.message;
      if (kDebugMode) {
        print('❌ ApiException in getSuggestion: ${e.message}');
        print('Status code: ${e.statusCode}');
        print('═══════════════════════════════════════════════════════════');
        print('=== GET PROMPT SUGGESTION: ERROR ===');
        print('═══════════════════════════════════════════════════════════');
      }
      _showMessage(context, e.message);
    } catch (e) {
      errorMessage =
          'Oops! Couldn\'t generate a suggestion. Give it another try!';
      if (kDebugMode) {
        print('❌ Unexpected error in getSuggestion: $e');
        print('Error type: ${e.runtimeType}');
        print('═══════════════════════════════════════════════════════════');
        print('=== GET PROMPT SUGGESTION: ERROR ===');
        print('═══════════════════════════════════════════════════════════');
      }
      _showMessage(context, errorMessage!);
    } finally {
      isGettingSuggestion = false;
      notifyListeners();
    }
  }

  Future<void> createWallpaper(BuildContext context) async {
    if (isCreating) return;

    final prompt = promptController.text.trim();
    if (prompt.isEmpty) {
      _showMessage(
        context,
        'Let your creativity flow! Enter a prompt to begin',
      );
      return;
    }

    final size = selectedSize;
    final style = selectedStyle;

    final signInViewModel = context.read<SignInViewModel>();
    final accessToken = signInViewModel.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      _showMessage(context, 'Sign in to start creating amazing wallpapers');
      return;
    }

    isCreating = true;
    creationProgress = 0.0;
    errorMessage = null;
    _startProgressAnimation();
    notifyListeners();

    try {
      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════════');
        print('=== CREATE WALLPAPER: START ===');
        print('═══════════════════════════════════════════════════════════');
        print('Prompt: $prompt');
        print('Size: $size');
        print('Style: $style');
        print('Access token present: ${accessToken.isNotEmpty}');
      }

      createdWallpaper = await _wallpaperRepository.createWallpaper(
        prompt: prompt,
        size: size,
        style: style,
        accessToken: accessToken,
      );

      if (kDebugMode) {
        print('✅ Wallpaper created successfully!');
        print('Wallpaper ID: ${createdWallpaper?.id}');
        print('Image URL: ${createdWallpaper?.imageUrl}');
        print('═══════════════════════════════════════════════════════════');
        print('=== CREATE WALLPAPER: SUCCESS ===');
        print('═══════════════════════════════════════════════════════════');
      }

      if (createdWallpaper != null &&
          createdWallpaper!.imageUrl.isNotEmpty &&
          createdWallpaper!.imageUrl != 'null') {
        creationProgress = 1.0;
        _currentStage = 'Complete!';
        notifyListeners();

        _showMessage(context, 'Wallpaper created successfully', isError: false);
        InAppReviewService.recordCompletedGenerationAndMaybeReview(context);
        Navigator.pushNamed(
          context,
          RoutesName.ImageCreatedScreen,
          arguments: createdWallpaper,
        );

        isCreating = false;
        _stopProgressAnimation();
        _stopPolling();
        notifyListeners();
      } else {
        _currentStage = 'Generating your masterpiece...';
        _pollingStartTime = DateTime.now();
        _startPolling(context, signInViewModel, accessToken);
        notifyListeners();
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401 && e.message.toLowerCase().contains('token')) {
        if (kDebugMode) {
          print('🔄 Token expired, attempting to refresh...');
        }

        final refreshed = await signInViewModel.refreshTokenSilently();

        if (refreshed && signInViewModel.accessToken != null) {
          if (kDebugMode) {
            print('✅ Token refreshed, retrying wallpaper creation...');
          }

          try {
            createdWallpaper = await _wallpaperRepository.createWallpaper(
              prompt: prompt,
              size: size,
              style: style,
              accessToken: signInViewModel.accessToken!,
            );

            if (kDebugMode) {
              print('✅ Wallpaper created successfully after token refresh!');
              print('Wallpaper ID: ${createdWallpaper?.id}');
              print('Image URL: ${createdWallpaper?.imageUrl}');
            }

            if (createdWallpaper != null &&
                createdWallpaper!.imageUrl.isNotEmpty &&
                createdWallpaper!.imageUrl != 'null') {
              creationProgress = 1.0;
              _currentStage = 'Complete!';
              notifyListeners();

              _showMessage(
                context,
                'Wallpaper created successfully',
                isError: false,
              );
              InAppReviewService.recordCompletedGenerationAndMaybeReview(
                context,
              );
              Navigator.pushNamed(
                context,
                RoutesName.ImageCreatedScreen,
                arguments: createdWallpaper,
              );

              isCreating = false;
              _stopProgressAnimation();
              _stopPolling();
              notifyListeners();
            } else {
              _currentStage = 'Generating your masterpiece...';
              _pollingStartTime = DateTime.now();
              _startPolling(
                context,
                signInViewModel,
                signInViewModel.accessToken!,
              );
              notifyListeners();
            }
            return;
          } catch (retryError) {
            if (kDebugMode) {
              print('❌ Retry failed after token refresh: $retryError');
            }
          }
        } else {
          if (kDebugMode) {
            print('❌ Failed to refresh token, user needs to login again');
          }
          _stopProgressAnimation();
          _stopPolling();
          isCreating = false;
          notifyListeners();

          if (context.mounted) {
            _showMessage(context, 'Session expired. Please login again.');
            Navigator.pushNamedAndRemoveUntil(
              context,
              RoutesName.SignInScreen,
              (route) => false,
            );
          }
          return;
        }
      }

      errorMessage = e.message;
      if (kDebugMode) {
        print('❌ ApiException in createWallpaper: ${e.message}');
        print('Status code: ${e.statusCode}');
        print('═══════════════════════════════════════════════════════════');
        print('=== CREATE WALLPAPER: ERROR ===');
        print('═══════════════════════════════════════════════════════════');
      }
      _stopProgressAnimation();
      _stopPolling();
      _showMessage(context, e.message);
    } catch (e) {
      errorMessage =
          'Hmm, something unexpected happened. Let\'s try that again!';
      if (kDebugMode) {
        print('❌ Unexpected error in createWallpaper: $e');
        print('Error type: ${e.runtimeType}');
        print('═══════════════════════════════════════════════════════════');
        print('=== CREATE WALLPAPER: ERROR ===');
        print('═══════════════════════════════════════════════════════════');
      }
      _stopProgressAnimation();
      _stopPolling();
      _showMessage(context, errorMessage!);
    } finally {
      if (!_isPolling) {
        isCreating = false;
        _stopProgressAnimation();
      }
      notifyListeners();
    }
  }

  void _startProgressAnimation() {
    _progressTimer?.cancel();
    creationProgress = 0.0;
    _currentStage = 'Generating your masterpiece...';

    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!isCreating) {
        timer.cancel();
        return;
      }

      if (creationProgress < 0.99) {
        creationProgress += 0.01;
      } else {
        creationProgress = 0.99;
      }

      notifyListeners();
    });
  }

  void _stopProgressAnimation() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  void _startPolling(
    BuildContext context,
    SignInViewModel signInViewModel,
    String accessToken,
  ) {
    if (createdWallpaper == null || createdWallpaper!.id.isEmpty) return;

    _isPolling = true;
    _pollingAttempts = 0;
    _pollingTimer?.cancel();

    String currentAccessToken = accessToken;

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!isCreating || !_isPolling) {
        timer.cancel();
        return;
      }

      _pollingAttempts++;

      // Check timeout
      if (_pollingAttempts >= _maxPollingAttempts) {
        _stopPolling();
        isCreating = false;
        _stopProgressAnimation();
        errorMessage =
            'Your masterpiece is taking a bit longer than usual. Feel free to try again!';
        if (context.mounted) {
          _showMessage(context, errorMessage!);
        }
        notifyListeners();
        return;
      }

      try {
        if (kDebugMode && _pollingAttempts % 6 == 0) {
          // Log every 30 seconds (6 attempts * 5 seconds)
          print(
            '⏳ Polling attempt $_pollingAttempts - Elapsed: ${elapsedPollingTimeFormatted}',
          );
          print('   Wallpaper ID: ${createdWallpaper!.id}');
          print(
            '   Current progress: ${(creationProgress * 100).toStringAsFixed(1)}%',
          );
          print('   Current stage: $_currentStage');
        }

        final updatedWallpaper = await _wallpaperRepository.getWallpaperById(
          wallpaperId: createdWallpaper!.id,
          accessToken: currentAccessToken,
        );

        if (updatedWallpaper != null) {
          if (updatedWallpaper.imageUrl.isNotEmpty &&
              updatedWallpaper.imageUrl != 'null') {
            // Image is ready!
            final attempts = _pollingAttempts;
            final elapsed = elapsedPollingTimeFormatted;
            createdWallpaper = updatedWallpaper;
            _stopPolling();
            creationProgress = 1.0;
            _currentStage = 'Complete!';
            notifyListeners();

            if (kDebugMode) {
              print('✅ Image is ready! URL: ${updatedWallpaper.imageUrl}');
              print('⏱️ Total polling attempts: $attempts');
              print('⏱️ Total elapsed time: $elapsed');
            }

            // Navigate to image created screen
            if (context.mounted) {
              _showMessage(
                context,
                'Your masterpiece is ready!',
                isError: false,
              );
              InAppReviewService.recordCompletedGenerationAndMaybeReview(
                context,
              );
              Navigator.pushNamed(
                context,
                RoutesName.ImageCreatedScreen,
                arguments: createdWallpaper,
              );
            }

            // Reset state
            isCreating = false;
            _stopProgressAnimation();
            notifyListeners();
          }
        }
      } on ApiException catch (e) {
        // Handle token expiration during polling
        if (e.statusCode == 401 && e.message.toLowerCase().contains('token')) {
          if (kDebugMode) {
            print('🔄 Token expired during polling, attempting to refresh...');
          }

          // Try to refresh the token
          final refreshed = await signInViewModel.refreshTokenSilently();

          if (refreshed && signInViewModel.accessToken != null) {
            if (kDebugMode) {
              print('✅ Token refreshed during polling, continuing...');
            }
            // Update the access token for next polling attempt
            currentAccessToken = signInViewModel.accessToken!;
          } else {
            if (kDebugMode) {
              print('❌ Failed to refresh token during polling');
            }
            // Stop polling if token refresh fails
            _stopPolling();
            isCreating = false;
            _stopProgressAnimation();
            notifyListeners();
            timer.cancel();

            // Navigate to login screen
            if (context.mounted) {
              _showMessage(context, 'Session expired. Please login again.');
              Navigator.pushNamedAndRemoveUntil(
                context,
                RoutesName.SignInScreen,
                (route) => false,
              );
            }
          }
        } else {
          if (kDebugMode) {
            print('❌ Error polling wallpaper status: ${e.message}');
            print(
              '   Attempt: $_pollingAttempts, Elapsed: ${elapsedPollingTimeFormatted}',
            );
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error polling wallpaper status: $e');
          print(
            '   Attempt: $_pollingAttempts, Elapsed: ${elapsedPollingTimeFormatted}',
          );
        }
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
    _pollingAttempts = 0;
    _pollingStartTime = null;
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    SnackbarUtil.showTopSnackBar(context, message, isError: isError);
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _pollingTimer?.cancel();
    promptController.dispose();
    super.dispose();
  }
}
