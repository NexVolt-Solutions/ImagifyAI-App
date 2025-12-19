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
  String? errorMessage;
  Wallpaper? createdWallpaper;
  
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

      // Complete progress
      creationProgress = 1.0;
      notifyListeners();
      
      _showMessage(context, 'Wallpaper created successfully', isError: false);
      Navigator.pushNamed(
        context,
        RoutesName.ImageCreatedScreen,
        arguments: createdWallpaper,
      );
    } on ApiException catch (e) {
      errorMessage = e.message;
      if (kDebugMode) {
        print('❌ ApiException in createWallpaper: ${e.message}');
        print('Status code: ${e.statusCode}');
        print('═══════════════════════════════════════════════════════════');
        print('=== CREATE WALLPAPER: ERROR ===');
        print('═══════════════════════════════════════════════════════════');
      }
      // Stop progress
      _stopProgressAnimation();
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
      // Stop progress
      _stopProgressAnimation();
      _showMessage(context, errorMessage!);
    } finally {
      isCreating = false;
      _stopProgressAnimation();
      notifyListeners();
    }
  }

  void _startProgressAnimation() {
    _progressTimer?.cancel();
    creationProgress = 0.0;
    
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!isCreating) {
        timer.cancel();
        return;
      }
      
      // Gradually increase progress from 0 to 99%
      if (creationProgress < 0.9) {
        creationProgress += 0.02; // Increase by 2% every 100ms
      } else if (creationProgress < 0.95) {
        creationProgress += 0.01; // Slow down near the end
      } else if (creationProgress < 0.99) {
        creationProgress += 0.005; // Even slower
      } else {
        creationProgress = 0.99; // Cap at 99% until API completes
      }
      
      notifyListeners();
    });
  }
  
  void _stopProgressAnimation() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  void _showMessage(BuildContext context, String message, {bool isError = true}) {
    SnackbarUtil.showTopSnackBar(context, message, isError: isError);
  }
  
  @override
  void dispose() {
    _progressTimer?.cancel();
    promptController.dispose();
    super.dispose();
  }
}

