import 'dart:async';
import 'package:flutter/material.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/Core/services/generation_limit_service.dart';
import 'package:imagifyai/Core/services/in_app_review_service.dart';
import 'package:imagifyai/Core/utils/Routes/routes_name.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:imagifyai/models/wallpaper/wallpaper.dart';
import 'package:imagifyai/domain/repositories/wallpaper_repository_interface.dart';
import 'package:imagifyai/domain/repositories/wallpaper_repository.dart';
import 'package:imagifyai/viewModel/sign_in_view_model.dart';
import 'package:provider/provider.dart';

class ImageGenerateViewModel extends ChangeNotifier {
  ImageGenerateViewModel({IWallpaperRepository? wallpaperRepository})
    : _wallpaperRepository = wallpaperRepository ?? WallpaperRepository();

  final IWallpaperRepository _wallpaperRepository;

  int selectedIndex = -1;
  int selectedStyleIndex = -1;
  int selectedPromptIndex = -1;
  bool isCreating = false;
  double creationProgress = 0.0;
  Timer? _progressTimer;
  Timer? _pollingTimer;
  String? errorMessage;
  Wallpaper? createdWallpaper;

  // 👈 Flag to skip clearing when navigating from Library
  bool _promptSetFromLibrary = false;

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
    // Backend does not accept "default"; use a valid style fallback.
    if (styles.isNotEmpty) {
      return styles.first;
    }
    return 'Colorful';
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

  /// Sets prompt (and optional style) when navigating from Library "Use This Prompt".
  void setPromptFromLibrary(String prompt, {String? styleName}) {
    _promptSetFromLibrary = true; // 👈 Raise flag so clear is skipped
    promptController.text = prompt;
    selectedIndex = 0;
    selectedPromptIndex = -1;
    if (styleName != null && styleName.isNotEmpty && _stylesMap.isNotEmpty) {
      final styleIndex = _stylesMap.keys.toList().indexOf(styleName);
      selectedStyleIndex = styleIndex >= 0 ? styleIndex : -1;
    } else {
      selectedStyleIndex = -1;
    }
    errorMessage = null;
    notifyListeners();
  }

  /// Clears prompt and style/size selections. Call when user leaves and comes
  /// back to the generation screen so the form is fresh.
  void clearPromptAndSelections() {
    // 👈 If coming from Library, skip clearing and consume the flag
    if (_promptSetFromLibrary) {
      _promptSetFromLibrary = false;
      return;
    }
    promptController.clear();
    selectedIndex = -1;
    selectedStyleIndex = -1;
    selectedPromptIndex = -1;
    errorMessage = null;
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
      return;
    }

    isLoadingStyles = true;
    stylesError = null;
    notifyListeners();

    try {
      _stylesMap = await _wallpaperRepository.fetchStyles(
        accessToken: accessToken,
      );
    } on ApiException catch (e) {
      stylesError = e.message;
    } catch (e) {
      stylesError = 'Failed to load styles';
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
      final response = await _wallpaperRepository.suggestPrompt(
        prompt: currentPrompt,
        accessToken: accessToken,
      );

      if (response.suggestion != null && response.suggestion!.isNotEmpty) {
        promptController.text = response.suggestion!;
        notifyListeners();
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
      _showMessage(context, e.message);
    } catch (e) {
      errorMessage =
          'Oops! Couldn\'t generate a suggestion. Give it another try!';
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
      createdWallpaper = await _wallpaperRepository.createWallpaper(
        prompt: prompt,
        size: size,
        style: style,
        accessToken: accessToken,
      );
      if (createdWallpaper != null &&
          createdWallpaper!.imageUrl.isNotEmpty &&
          createdWallpaper!.imageUrl != 'null') {
        creationProgress = 1.0;
        _currentStage = 'Complete!';
        notifyListeners();

        _showMessage(context, 'Wallpaper created successfully', isError: false);
        await GenerationLimitService.recordGeneration();
        InAppReviewService.recordCompletedGenerationAndMaybeReview(context);
        Navigator.pushNamed(
          context,
          RoutesName.ImageCreatedScreen,
          arguments: createdWallpaper,
        ).then((_) => clearPromptAndSelections());

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
        final refreshed = await signInViewModel.refreshTokenSilently();

        if (refreshed && signInViewModel.accessToken != null) {
          try {
            createdWallpaper = await _wallpaperRepository.createWallpaper(
              prompt: prompt,
              size: size,
              style: style,
              accessToken: signInViewModel.accessToken!,
            );
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
              await GenerationLimitService.recordGeneration();
              InAppReviewService.recordCompletedGenerationAndMaybeReview(
                context,
              );
              Navigator.pushNamed(
                context,
                RoutesName.ImageCreatedScreen,
                arguments: createdWallpaper,
              ).then((_) => clearPromptAndSelections());

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
            // ignore
          }
        } else {
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
      _stopProgressAnimation();
      _stopPolling();
      _showMessage(context, e.message);
    } catch (e) {
      errorMessage =
          'Hmm, something unexpected happened. Let\'s try that again!';
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
        final updatedWallpaper = await _wallpaperRepository.getWallpaperById(
          wallpaperId: createdWallpaper!.id,
          accessToken: currentAccessToken,
        );

        if (updatedWallpaper != null) {
          if (updatedWallpaper.imageUrl.isNotEmpty &&
              updatedWallpaper.imageUrl != 'null') {
            createdWallpaper = updatedWallpaper;
            _stopPolling();
            creationProgress = 1.0;
            _currentStage = 'Complete!';
            notifyListeners();

            if (context.mounted) {
              _showMessage(
                context,
                'Your masterpiece is ready!',
                isError: false,
              );
              await GenerationLimitService.recordGeneration();
              InAppReviewService.recordCompletedGenerationAndMaybeReview(
                context,
              );
              Navigator.pushNamed(
                context,
                RoutesName.ImageCreatedScreen,
                arguments: createdWallpaper,
              ).then((_) => clearPromptAndSelections());
            }

            isCreating = false;
            _stopProgressAnimation();
            notifyListeners();
          }
        }
      } on ApiException catch (e) {
        if (e.statusCode == 401 && e.message.toLowerCase().contains('token')) {
          final refreshed = await signInViewModel.refreshTokenSilently();

          if (refreshed && signInViewModel.accessToken != null) {
            currentAccessToken = signInViewModel.accessToken!;
          } else {
            _stopPolling();
            isCreating = false;
            _stopProgressAnimation();
            notifyListeners();
            timer.cancel();

            if (context.mounted) {
              _showMessage(context, 'Session expired. Please login again.');
              Navigator.pushNamedAndRemoveUntil(
                context,
                RoutesName.SignInScreen,
                (route) => false,
              );
            }
          }
        }
      } catch (e) {
        // ignore polling errors
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
