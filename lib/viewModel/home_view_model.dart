import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/Core/services/in_app_review_service.dart';
import 'package:imagifyai/Core/services/token_storage_service.dart';
import 'package:imagifyai/Core/utils/Routes/routes_name.dart';
import 'package:imagifyai/Core/utils/jwt_decoder.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:imagifyai/models/user/user.dart';
import 'package:imagifyai/models/wallpaper/suggest_response.dart';
import 'package:imagifyai/models/wallpaper/wallpaper.dart';
import 'package:imagifyai/domain/repositories/auth_repository_interface.dart';
import 'package:imagifyai/domain/repositories/wallpaper_repository_interface.dart';
import 'package:imagifyai/domain/repositories/auth_repository.dart';
import 'package:imagifyai/domain/repositories/wallpaper_repository.dart';
import 'package:imagifyai/viewModel/bottom_nav_screen_view_model.dart';
import 'package:imagifyai/viewModel/sign_in_view_model.dart';
import 'package:provider/provider.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    IWallpaperRepository? wallpaperRepository,
    IAuthRepository? authRepository,
  }) : _wallpaperRepository = wallpaperRepository ?? WallpaperRepository(),
       _authRepository = authRepository ?? AuthRepository();

  final IWallpaperRepository _wallpaperRepository;
  final IAuthRepository _authRepository;

  final promptController = TextEditingController();
  final sizeController = TextEditingController(text: '1:1');
  final styleController = TextEditingController(text: 'default');
  final titleController = TextEditingController();
  final aiModelController = TextEditingController(text: 'default');
  bool isLoading = false;
  bool isCreating = false;
  bool isLoadingUser = false;
  bool isLoadingGroupedWallpapers = false;
  String? suggestion;
  String? errorMessage;
  Wallpaper? createdWallpaper;
  User? currentUser;

  /// Bumped when profile image updates so home header refetches the image.
  int _profileImageCacheNonce = 0;
  int get profileImageCacheNonce => _profileImageCacheNonce;

  void bumpProfileImageCacheNonce() {
    _profileImageCacheNonce++;
    notifyListeners();
  }

  Map<String, List<Wallpaper>> groupedWallpapers = {};
  int _groupedWallpapersLoadSeq = 0;

  int selectedIndex = 0;
  int selectedSizeIndex = 0; // Default to first size (1:1)
  int selectedStyleIndex = -1; // No style selected by default

  // Sizes matching backend SIZE_MAP
  final List<Map<String, dynamic>> sizes = [
    {'text1': '1:1', 'text2': 'Square'},
    {'text1': '2:3 Portrait', 'text2': 'Portrait'},
    {'text1': '2:3 Landscape', 'text2': 'Landscape'},
  ];

  // Styles fetched from API (keys are style names, values are style suffixes)
  Map<String, String> _stylesMap = {};
  List<String> get styles => _stylesMap.keys.toList();
  bool isLoadingStyles = false;
  String? stylesError;

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

  Future<void> loadCurrentUser(
    BuildContext context, {
    bool forceReload = false,
  }) async {
    if (isLoadingUser && !forceReload) {
      return;
    }

    // Get access token from SignInViewModel first
    final signInViewModel = context.read<SignInViewModel>();
    await signInViewModel.ensureTokensLoaded();
    String? accessToken = signInViewModel.accessToken;

    // If SignInViewModel doesn't have token yet, try loading directly from storage
    // This handles the race condition where HomeViewModel loads before SignInViewModel finishes loading tokens
    if (accessToken == null || accessToken.isEmpty) {
      try {
        accessToken = await TokenStorageService.getAccessToken();
      } catch (_) {}
    }

    if (accessToken == null || accessToken.isEmpty) {
      // User not logged in, clear cached user and skip loading
      if (currentUser != null) {
        currentUser = null;
        notifyListeners();
      }
      return;
    }

    // Proactively refresh before GET /user so we don't hit 401 + error snackbars.
    await signInViewModel.ensureAccessTokenFresh();
    accessToken =
        signInViewModel.accessToken ??
        await TokenStorageService.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      if (currentUser != null) {
        currentUser = null;
        notifyListeners();
      }
      return;
    }

    // At this point, accessToken is guaranteed to be non-null and non-empty
    final String validAccessToken = accessToken;

    // Get userId from storage to check if user changed
    String? userId = await TokenStorageService.getUserId();

    // If userId is not in storage, try to extract it from JWT token
    if (userId == null || userId.isEmpty) {
      try {
        userId = JwtDecoder.getUserId(validAccessToken);

        if (userId != null && userId.isNotEmpty) {
          await TokenStorageService.saveUserId(userId);
        }
      } catch (_) {}
    }

    if (userId == null || userId.isEmpty) {
      // No user ID means not logged in, clear cached user
      if (currentUser != null) {
        currentUser = null;
        notifyListeners();
      }
      return;
    }

    // On forceReload, keep showing the previous user until fetch completes
    // so the header never flashes empty / generic placeholder.
    if (!forceReload && currentUser != null) {
      if (currentUser!.id == userId) {
        return;
      } else {
        // Clear cached user since it's a different user
        currentUser = null;
        notifyListeners();
      }
    }

    isLoadingUser = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await _authRepository.getCurrentUser(
        accessToken: validAccessToken,
        userId: userId,
        forceRefresh: forceReload,
      );
      errorMessage = null; // Clear any previous errors on success
    } on ApiException catch (e) {
      // Handle token expiration - automatically refresh and retry
      // Only refresh on actual expiration errors, not "missing user_id" or other validation errors
      final messageLower = e.message.toLowerCase();
      final isTokenExpired =
          e.statusCode == 401 &&
          (messageLower.contains('expired') &&
              !messageLower.contains('missing'));

      if (isTokenExpired) {
        // Get SignInViewModel to refresh token
        final signInViewModel = context.read<SignInViewModel>();

        // Try to refresh the token
        final refreshed = await signInViewModel.refreshTokenSilently();

        if (refreshed && signInViewModel.accessToken != null) {
          // Retry the request with new token
          try {
            // Ensure we have the latest token from SignInViewModel
            final refreshedAccessToken = signInViewModel.accessToken;
            if (refreshedAccessToken == null || refreshedAccessToken.isEmpty) {
              // Fallback: try loading from storage
              final tokenFromStorage =
                  await TokenStorageService.getAccessToken();
              if (tokenFromStorage != null && tokenFromStorage.isNotEmpty) {
                currentUser = await _authRepository.getCurrentUser(
                  accessToken: tokenFromStorage,
                  userId: userId,
                  forceRefresh: forceReload,
                );
              } else {
                throw Exception('No access token available after refresh');
              }
            } else {
              currentUser = await _authRepository.getCurrentUser(
                accessToken: refreshedAccessToken,
                userId: userId,
                forceRefresh: forceReload,
              );
            }
            errorMessage = null; // Clear any previous errors on success
          } on ApiException catch (retryError) {
            // If retry also fails with 401, don't retry again (avoid infinite loop)
            if (retryError.statusCode == 401) {
              errorMessage = 'Session expired. Please login again.';
            } else {
              errorMessage =
                  'Couldn\'t load your profile. Let\'s try refreshing!';
            }
            currentUser = null;
          } catch (retryError) {
            errorMessage =
                'Couldn\'t load your profile. Let\'s try refreshing!';
            currentUser = null;
          }
        } else {
          errorMessage = 'Session expired. Please login again.';
          currentUser = null;
        }
      } else {
        errorMessage = e.message;
        // Set currentUser to null so UI doesn't try to display invalid data
        currentUser = null;
      }
    } catch (e) {
      errorMessage = 'Couldn\'t load your profile. Let\'s try refreshing!';
      currentUser = null;
    } finally {
      isLoadingUser = false;
      notifyListeners();
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
    final title = titleController.text.trim().isNotEmpty
        ? titleController.text.trim()
        : prompt;
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
      InAppReviewService.recordCompletedGenerationAndMaybeReview(context);
      loadGroupedWallpapers(context, force: true);
      Navigator.pushNamed(
        context,
        RoutesName.ImageCreatedScreen,
        arguments: createdWallpaper,
      );
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

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    SnackbarUtil.showTopSnackBar(context, message, isError: isError);
  }

  void navigateToGenerateWallpaperScreen(BuildContext context) {
    // Update BottomNavScreenViewModel's index to 1 (Create Image tab)
    // This will change the displayed screen and update the bottom navigation bar
    final bottomNavViewModel = context.read<BottomNavScreenViewModel>();
    bottomNavViewModel.updateIndex(1);
  }

  /// Ensures storage-backed tokens are loaded and the access token is refreshed
  /// if near expiry. Call this before parallel style/wallpaper requests so they
  /// do not race [loadCurrentUser]'s refresh and hit 401 with a stale JWT
  /// (empty Home after hot restart).
  Future<void> prepareAuthTokens(BuildContext context) async {
    final signInViewModel = context.read<SignInViewModel>();
    await signInViewModel.ensureTokensLoaded();
    await signInViewModel.ensureAccessTokenFresh();
  }

  /// Refresh home screen data (user and grouped wallpapers)
  Future<void> refreshHomeData(BuildContext context) async {
    await prepareAuthTokens(context);
    if (!context.mounted) return;

    // Load all data in parallel for faster refresh
    await Future.wait([
      loadCurrentUser(context, forceReload: true),
      loadStyles(context),
      loadGroupedWallpapers(context, force: true),
    ]);
  }

  /// Load styles from the API
  Future<void> loadStyles(BuildContext context) async {
    if (isLoadingStyles || _stylesMap.isNotEmpty) return;

    // Get access token from SignInViewModel
    final signInViewModel = context.read<SignInViewModel>();
    String? accessToken = signInViewModel.accessToken;

    // If not available in SignInViewModel, try loading from storage
    if (accessToken == null || accessToken.isEmpty) {
      try {
        accessToken = await TokenStorageService.getAccessToken();
      } catch (_) {}
    }

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
    } catch (_) {
      stylesError = 'Failed to load styles';
    } finally {
      isLoadingStyles = false;
      notifyListeners();
    }
  }

  /// Load grouped wallpapers from the API (`GET .../wallpapers/grouped?page=&limit=`).
  /// Pass [force] after creating a wallpaper or switching back to Home so the list is not stale.
  Future<void> loadGroupedWallpapers(
    BuildContext context, {
    bool force = false,
  }) async {
    if (isLoadingGroupedWallpapers && !force) return;

    // Try to get access token from SignInViewModel first
    final signInViewModel = context.read<SignInViewModel>();
    String? accessToken = signInViewModel.accessToken;

    // If not available in SignInViewModel, try loading from storage
    if (accessToken == null || accessToken.isEmpty) {
      try {
        accessToken = await TokenStorageService.getAccessToken();
      } catch (_) {}
    }

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    final loadSeq = ++_groupedWallpapersLoadSeq;
    isLoadingGroupedWallpapers = true;
    errorMessage = null;
    notifyListeners();

    try {
      final grouped = await _wallpaperRepository.fetchGroupedWallpapers(
        accessToken: accessToken,
        page: 1,
        limit: 10,
      );
      if (!context.mounted || loadSeq != _groupedWallpapersLoadSeq) return;
      groupedWallpapers = grouped;
      errorMessage = null;
    } on ApiException catch (e) {
      if (context.mounted && loadSeq == _groupedWallpapersLoadSeq) {
        errorMessage = e.message;
      }
      // Don't show error to user, just log it
    } catch (e) {
      if (context.mounted && loadSeq == _groupedWallpapersLoadSeq) {
        errorMessage = 'Failed to load wallpapers';
      }
    } finally {
      if (loadSeq == _groupedWallpapersLoadSeq) {
        isLoadingGroupedWallpapers = false;
        notifyListeners();
      }
    }
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
