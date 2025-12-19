import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/services/token_storage_service.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/Core/utils/snackbar_util.dart';
import 'package:genwalls/models/user/user.dart';
import 'package:genwalls/models/wallpaper/suggest_response.dart';
import 'package:genwalls/models/wallpaper/wallpaper.dart';
import 'package:genwalls/repositories/auth_repository.dart';
import 'package:genwalls/repositories/wallpaper_repository.dart';
import 'package:genwalls/viewModel/bottom_nav_screen_view_model.dart';
import 'package:genwalls/viewModel/sign_in_view_model.dart';
import 'package:provider/provider.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    WallpaperRepository? wallpaperRepository,
    AuthRepository? authRepository,
  })  : _wallpaperRepository = wallpaperRepository ?? WallpaperRepository(),
        _authRepository = authRepository ?? AuthRepository();

  final WallpaperRepository _wallpaperRepository;
  final AuthRepository _authRepository;

  final promptController = TextEditingController();
  final sizeController = TextEditingController(text: '1:1');
  final styleController = TextEditingController(text: 'default');
  final titleController = TextEditingController();
  final aiModelController = TextEditingController(text: 'default');
  bool isLoading = false;
  bool isCreating = false;
  bool isLoadingUser = false;
  String? suggestion;
  String? errorMessage;
  Wallpaper? createdWallpaper;
  User? currentUser;

  int selectedIndex = 0;
  int selectedSizeIndex = 0; // Default to first size (1:1)
  int selectedStyleIndex = -1; // No style selected by default

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
    if (selectedSizeIndex >= 0 && selectedSizeIndex < sizes.length) {
      return sizes[selectedSizeIndex]['text1'] as String;
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

  List<Map<String, dynamic>> bottomData = [
    {'name': 'Home', 'image': AppAssets.homeIcon},
    {'name': 'Create Image', 'image': AppAssets.imageIcon},
    {'name': 'My Profile', 'image': AppAssets.bottomProfileIcon},
  ];

  void onTapFun(BuildContext context, int index) {
    selectedIndex = index;

    if (index == 0) {
      Navigator.pushNamed(context, RoutesName.HomeScreen);
    } else if (index == 1) {
      Navigator.pushNamed(context, RoutesName.ImageGenerateScreen);
    } else if (index == 2) {
      Navigator.pushNamed(context, RoutesName.ProfileScreen);
    }
    notifyListeners();
  }

  Future<void> loadCurrentUser(BuildContext context, {bool forceReload = false}) async {
    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('=== HOME VIEW MODEL: loadCurrentUser CALLED ===');
      print('═══════════════════════════════════════════════════════════');
      print('forceReload: $forceReload');
      print('isLoadingUser: $isLoadingUser');
      print('currentUser: ${currentUser != null ? "exists" : "null"}');
    }
    
    if (isLoadingUser) {
      if (kDebugMode) {
        print('⚠️  Already loading user, skipping...');
      }
      return;
    }
    
    // Skip if user data already loaded and not forcing reload
    if (!forceReload && currentUser != null) {
      if (kDebugMode) {
        print('⚠️  User already loaded, skipping...');
      }
      return;
    }

    // Get access token from SignInViewModel
    final signInViewModel = context.read<SignInViewModel>();
    final accessToken = signInViewModel.accessToken;

    if (kDebugMode) {
      print('--- Token Check ---');
      print('Access token from SignInViewModel: ${accessToken != null && accessToken.isNotEmpty ? "Present" : "Missing"}');
      if (accessToken != null) {
        print('Access token length: ${accessToken.length}');
        print('Access token preview: ${accessToken.substring(0, accessToken.length > 30 ? 30 : accessToken.length)}...');
      }
    }

    if (accessToken == null || accessToken.isEmpty) {
      // User not logged in, skip loading
      if (kDebugMode) {
        print('❌ No access token available, skipping user load');
        print('═══════════════════════════════════════════════════════════');
        print('=== HOME VIEW MODEL: loadCurrentUser END (NO TOKEN) ===');
        print('═══════════════════════════════════════════════════════════');
      }
      return;
    }

    if (kDebugMode) {
      print('✅ Access token available, proceeding to load user...');
    }

    isLoadingUser = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Get userId from TokenStorageService
      final userId = await TokenStorageService.getUserId();
      if (userId == null || userId.isEmpty) {
        throw ApiException('User ID is required. Please login again.');
      }

      if (kDebugMode) {
        print('--- Calling AuthRepository.getCurrentUser ---');
        print('User ID from storage: $userId');
      }
      currentUser = await _authRepository.getCurrentUser(
        accessToken: accessToken,
        userId: userId,
      );
      errorMessage = null; // Clear any previous errors on success
      
      if (kDebugMode) {
        print('✅ User loaded successfully!');
        print('User ID: ${currentUser?.id}');
        print('Username: ${currentUser?.username}');
        print('Email: ${currentUser?.email}');
      }
    } on ApiException catch (e) {
      errorMessage = e.message;
      // Don't show error snackbar here, just log it
       if (kDebugMode) {
        print('❌ ApiException in loadCurrentUser: ${e.message}');
        if (e.statusCode == 403) {
          print('⚠️  Status Code: 403 Forbidden');
         }
      }
      // Set currentUser to null so UI doesn't try to display invalid data
      currentUser = null;
    } catch (e) {
      errorMessage = 'Couldn\'t load your profile. Let\'s try refreshing!';
      if (kDebugMode) {
        print('❌ Unexpected error in loadCurrentUser: $e');
        print('Error type: ${e.runtimeType}');
      }
      currentUser = null;
    } finally {
      isLoadingUser = false;
      notifyListeners();
      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════════');
        print('=== HOME VIEW MODEL: loadCurrentUser END ===');
        print('═══════════════════════════════════════════════════════════');
      }
    }
  }

  Future<void> fetchSuggestion(BuildContext context) async {
    if (isLoading) return;
    final prompt = promptController.text.trim();
    if (prompt.isEmpty) {
      _showMessage(context, 'Describe your vision to get started!');
      return;
    }

    // Get access token from SignInViewModel
    final signInViewModel = context.read<SignInViewModel>();
    final accessToken = signInViewModel.accessToken;
    
    if (accessToken == null || accessToken.isEmpty) {
      _showMessage(context, 'Sign in to unlock this amazing feature');
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final SuggestResponse response = await _wallpaperRepository.suggestPrompt(
        prompt: prompt,
        accessToken: accessToken,
      );
      suggestion = response.suggestion ?? 'No suggestion';
      _showMessage(context, 'Suggestion received', isError: false);
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      _showMessage(context, errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createWallpaper(BuildContext context) async {
    if (isCreating) return;
    final prompt = promptController.text.trim();
    if (prompt.isEmpty) {
      _showMessage(context, 'Describe your vision to get started!');
      return;
    }

    // Use selected size and style from the lists
    final size = selectedSize;
    final style = selectedStyle;
    final title =
        titleController.text.trim().isNotEmpty ? titleController.text.trim() : prompt;
    final aiModel = aiModelController.text.trim().isNotEmpty
        ? aiModelController.text.trim()
        : 'default';

    // Get access token from SignInViewModel
    final signInViewModel = context.read<SignInViewModel>();
    final accessToken = signInViewModel.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      _showMessage(context, 'Sign in to start creating your wallpapers');
      return;
    }

    isCreating = true;
    errorMessage = null;
    notifyListeners();

    try {
      createdWallpaper = await _wallpaperRepository.createWallpaper(
        prompt: prompt,
        size: size,
        style: style,
        title: title,
        aiModel: aiModel,
        accessToken: accessToken,
      );
      _showMessage(context, 'Wallpaper created successfully', isError: false);
      Navigator.pushNamed(context, RoutesName.ImageCreatedScreen, arguments: createdWallpaper);
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      _showMessage(context, errorMessage!);
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  void _showMessage(BuildContext context, String message, {bool isError = true}) {
    SnackbarUtil.showTopSnackBar(context, message, isError: isError);
  }

  void navigateToGenarateWallpaperScreen(BuildContext context) {
    // Update BottomNavScreenViewModel's index to 1 (Create Image tab)
    // This will change the displayed screen and update the bottom navigation bar
    final bottomNavViewModel = context.read<BottomNavScreenViewModel>();
    bottomNavViewModel.updateIndex(1);
  }
  @override
  void dispose() {
    promptController.dispose();
    sizeController.dispose();
    styleController.dispose();
    titleController.dispose();
    aiModelController.dispose();
    super.dispose();
  }
}
