import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/Core/utils/snackbar_util.dart';
import 'package:genwalls/models/wallpaper/wallpaper.dart';
import 'package:genwalls/repositories/wallpaper_repository.dart';
import 'package:genwalls/viewModel/sign_in_view_model.dart';
import 'package:provider/provider.dart';

class ImageGenerateViewModel extends ChangeNotifier {
  ImageGenerateViewModel({WallpaperRepository? wallpaperRepository})
      : _wallpaperRepository = wallpaperRepository ?? WallpaperRepository();

  final WallpaperRepository _wallpaperRepository;

  int selectedIndex = -1;
  int selectedStyleIndex = -1;
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
  static const int _maxPollingAttempts = 120; // 10 minutes max (120 attempts * 5 seconds)
  
  // Get elapsed polling time in seconds
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
  
  // Controller for the prompt text field
  final promptController = TextEditingController();

  // Sizes matching backend SIZE_MAP
  final List<Map<String, dynamic>> sizes = [
    {'text1': '1:1', 'text2': 'Square'},
    {'text1': '2:3 Portrait', 'text2': 'Portrait'},
    {'text1': '2:3 Landscape', 'text2': 'Landscape'},
  ];
  
  // Styles matching backend STYLE_SUFFIXES
  final List<String> styles = [
    'Colorful',
    '3D Render',
    '3D Cinematic',
    'Photorealistic',
    'Illustration',
    'Oil Painting',
    'Watercolor',
    'Cyberpunk',
    'Fantasy',
    'Anime',
    'Manga',
    'Cartoon',
    'Cartoon (Vector)',
    'Disney/Pixar',
    'Chibi',
    'Kawaii',
    'Cel-Shading',
    'Comic Strip',
    'Steampunk',
  ];
  
  // Get selected size value
  String get selectedSize {
    if (selectedIndex >= 0 && selectedIndex < sizes.length) {
      return sizes[selectedIndex]['text1'] as String;
    }
    return '1:1'; // Default
  }
  
  // Get selected style value
  String get selectedStyle {
    if (selectedStyleIndex >= 0 && selectedStyleIndex < styles.length) {
      return styles[selectedStyleIndex];
    }
    return 'default'; // Default
  }
  
  // Method to set prompt text when a predefined prompt is selected
  void setPromptText(String text) {
    promptController.text = text;
    notifyListeners();
  }
  
  bool isGettingSuggestion = false;
  
  Future<void> getSuggestion(BuildContext context) async {
    final currentPrompt = promptController.text.trim();
    
    if (currentPrompt.isEmpty) {
      _showMessage(context, 'Start by describing your vision!');
      return;
    }
    
    // Get access token from SignInViewModel
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
        // Update the prompt field with the suggestion
        promptController.text = response.suggestion!;
        notifyListeners();
        
        if (kDebugMode) {
          print('✅ Suggestion received: ${response.suggestion}');
          print('═══════════════════════════════════════════════════════════');
          print('=== GET PROMPT SUGGESTION: SUCCESS ===');
          print('═══════════════════════════════════════════════════════════');
        }
        
        _showMessage(context, 'AI suggestion ready! Check it out above', isError: false);
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
      errorMessage = 'Oops! Couldn\'t generate a suggestion. Give it another try!';
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
      _showMessage(context, 'Let your creativity flow! Enter a prompt to begin');
      return;
    }

    // Get selected size and style
    final size = selectedSize;
    final style = selectedStyle;

    // Get access token from SignInViewModel
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

      // Check if image is ready
      if (createdWallpaper != null && 
          createdWallpaper!.imageUrl.isNotEmpty && 
          createdWallpaper!.imageUrl != 'null') {
        // Image is ready, navigate immediately
        creationProgress = 1.0;
        _currentStage = 'Complete!';
        notifyListeners();
        
        _showMessage(context, 'Wallpaper created successfully', isError: false);
        Navigator.pushNamed(
          context,
          RoutesName.ImageCreatedScreen,
          arguments: createdWallpaper,
        );
        
        // Reset state
        isCreating = false;
        _stopProgressAnimation();
        _stopPolling();
        notifyListeners();
      } else {
        // Image is still generating, start polling
        _currentStage = 'Generating your masterpiece...';
        _pollingStartTime = DateTime.now();
        _startPolling(context, signInViewModel, accessToken);
        notifyListeners();
      }
    } on ApiException catch (e) {
      // Handle token expiration - automatically refresh and retry
      if (e.statusCode == 401 && e.message.toLowerCase().contains('token')) {
        if (kDebugMode) {
          print('🔄 Token expired, attempting to refresh...');
        }
        
        // Try to refresh the token
        final refreshed = await signInViewModel.refreshTokenSilently();
        
        if (refreshed && signInViewModel.accessToken != null) {
          if (kDebugMode) {
            print('✅ Token refreshed, retrying wallpaper creation...');
          }
          
          // Retry the request with new token
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

            // Check if image is ready
            if (createdWallpaper != null && 
                createdWallpaper!.imageUrl.isNotEmpty && 
                createdWallpaper!.imageUrl != 'null') {
              // Image is ready, navigate immediately
              creationProgress = 1.0;
              _currentStage = 'Complete!';
              notifyListeners();
              
              _showMessage(context, 'Wallpaper created successfully', isError: false);
              Navigator.pushNamed(
                context,
                RoutesName.ImageCreatedScreen,
                arguments: createdWallpaper,
              );
              
              // Reset state
              isCreating = false;
              _stopProgressAnimation();
              _stopPolling();
              notifyListeners();
            } else {
              // Image is still generating, start polling
              _currentStage = 'Generating your masterpiece...';
              _pollingStartTime = DateTime.now();
              _startPolling(context, signInViewModel, signInViewModel.accessToken!);
              notifyListeners();
            }
            return; // Success, exit early
          } catch (retryError) {
            if (kDebugMode) {
              print('❌ Retry failed after token refresh: $retryError');
            }
            // Fall through to show error message
          }
        } else {
          if (kDebugMode) {
            print('❌ Failed to refresh token, user needs to login again');
          }
          // Stop progress and polling
          _stopProgressAnimation();
          _stopPolling();
          isCreating = false;
          notifyListeners();
          
          // Navigate to login screen
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
      // Stop progress and polling
      _stopProgressAnimation();
      _stopPolling();
      _showMessage(context, e.message);
    } catch (e) {
      errorMessage = 'Hmm, something unexpected happened. Let\'s try that again!';
      if (kDebugMode) {
        print('❌ Unexpected error in createWallpaper: $e');
        print('Error type: ${e.runtimeType}');
        print('═══════════════════════════════════════════════════════════');
        print('=== CREATE WALLPAPER: ERROR ===');
        print('═══════════════════════════════════════════════════════════');
      }
      // Stop progress and polling
      _stopProgressAnimation();
      _stopPolling();
      _showMessage(context, errorMessage!);
    } finally {
      // Only set isCreating to false if we're not polling
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
  
  void _startPolling(BuildContext context, SignInViewModel signInViewModel, String accessToken) {
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
        errorMessage = 'Your masterpiece is taking a bit longer than usual. Feel free to try again!';
        if (context.mounted) {
          _showMessage(context, errorMessage!);
        }
        notifyListeners();
        return;
      }
      
      try {
        if (kDebugMode && _pollingAttempts % 6 == 0) {
          // Log every 30 seconds (6 attempts * 5 seconds)
          print('⏳ Polling attempt $_pollingAttempts - Elapsed: ${elapsedPollingTimeFormatted}');
          print('   Wallpaper ID: ${createdWallpaper!.id}');
          print('   Current progress: ${(creationProgress * 100).toStringAsFixed(1)}%');
          print('   Current stage: $_currentStage');
        }
        
        final updatedWallpaper = await _wallpaperRepository.getWallpaperById(
          wallpaperId: createdWallpaper!.id,
          accessToken: currentAccessToken,
        );
        
        if (updatedWallpaper != null) {
          if (updatedWallpaper.imageUrl.isNotEmpty && updatedWallpaper.imageUrl != 'null') {
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
              _showMessage(context, 'Your masterpiece is ready!', isError: false);
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
            print('   Attempt: $_pollingAttempts, Elapsed: ${elapsedPollingTimeFormatted}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error polling wallpaper status: $e');
          print('   Attempt: $_pollingAttempts, Elapsed: ${elapsedPollingTimeFormatted}');
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

  void _showMessage(BuildContext context, String message, {bool isError = true}) {
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

