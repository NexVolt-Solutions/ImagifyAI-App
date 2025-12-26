import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/services/token_storage_service.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/Core/utils/jwt_decoder.dart';
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

    // Get access token from SignInViewModel first
    final signInViewModel = context.read<SignInViewModel>();
    String? accessToken = signInViewModel.accessToken;

    if (kDebugMode) {
      print('--- Token Check ---');
      print('Access token from SignInViewModel: ${accessToken != null && accessToken.isNotEmpty ? "Present" : "Missing"}');
      if (accessToken != null) {
        print('Access token length: ${accessToken.length}');
        print('Access token preview: ${accessToken.substring(0, accessToken.length > 30 ? 30 : accessToken.length)}...');
      }
    }

    // If SignInViewModel doesn't have token yet, try loading directly from storage
    // This handles the race condition where HomeViewModel loads before SignInViewModel finishes loading tokens
    if (accessToken == null || accessToken.isEmpty) {
      if (kDebugMode) {
        print('⚠️  SignInViewModel token not available, trying to load from storage...');
      }
      try {
        accessToken = await TokenStorageService.getAccessToken();
        if (accessToken != null && accessToken.isNotEmpty) {
          // Update SignInViewModel with the token we just loaded
          // Note: We can't directly set private fields, but this ensures consistency
          if (kDebugMode) {
            print('✅ Token loaded from storage directly');
            print('Token length: ${accessToken.length}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error loading token from storage: $e');
        }
      }
    }

    if (accessToken == null || accessToken.isEmpty) {
      // User not logged in, clear cached user and skip loading
      if (currentUser != null) {
        currentUser = null;
        notifyListeners();
      }
      if (kDebugMode) {
        print('❌ No access token available, skipping user load');
        print('═══════════════════════════════════════════════════════════');
        print('=== HOME VIEW MODEL: loadCurrentUser END (NO TOKEN) ===');
        print('═══════════════════════════════════════════════════════════');
      }
      return;
    }

    // At this point, accessToken is guaranteed to be non-null and non-empty
    final String validAccessToken = accessToken;

    // Get userId from storage to check if user changed
    String? userId = await TokenStorageService.getUserId();
    
    // If userId is not in storage, try to extract it from JWT token
    if (userId == null || userId.isEmpty) {
      if (kDebugMode) {
        print('⚠️  User ID not found in storage, attempting to extract from JWT...');
      }
      
      try {
        // Try to extract userId from JWT token
        userId = JwtDecoder.getUserId(validAccessToken);
        
        if (userId != null && userId.isNotEmpty) {
          // Save the extracted userId to storage for future use
          await TokenStorageService.saveUserId(userId);
          if (kDebugMode) {
            print('✅ User ID extracted from JWT and saved: $userId');
          }
        } else {
          if (kDebugMode) {
            print('❌ User ID not found in JWT token either');
            // Try to decode and log JWT payload for debugging
            final decoded = JwtDecoder.decode(validAccessToken);
            if (decoded != null) {
              print('JWT Payload keys: ${decoded.keys.toList()}');
              print('JWT Payload: $decoded');
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error extracting userId from JWT: $e');
        }
      }
    }
    
    if (userId == null || userId.isEmpty) {
      // No user ID means not logged in, clear cached user
      if (currentUser != null) {
        currentUser = null;
        notifyListeners();
      }
      if (kDebugMode) {
        print('❌ No user ID available, skipping user load');
        print('═══════════════════════════════════════════════════════════');
        print('=== HOME VIEW MODEL: loadCurrentUser END (NO USER ID) ===');
        print('═══════════════════════════════════════════════════════════');
      }
      return;
    }

    // Check if the stored userId matches the cached user
    // If they don't match, clear cache and reload (user changed)
    if (!forceReload && currentUser != null) {
      if (currentUser!.id == userId) {
        if (kDebugMode) {
          print('✅ User already loaded and matches stored user ID, skipping...');
          print('Cached User ID: ${currentUser!.id}');
          print('Stored User ID: $userId');
        }
        return;
      } else {
        if (kDebugMode) {
          print('⚠️  User ID changed! Clearing cached user and reloading...');
          print('Cached User ID: ${currentUser!.id}');
          print('Stored User ID: $userId');
        }
        // Clear cached user since it's a different user
        currentUser = null;
        notifyListeners();
      }
    }

    if (kDebugMode) {
      print('✅ Access token available, proceeding to load user...');
      print('User ID from storage: $userId');
    }

    isLoadingUser = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('--- Calling AuthRepository.getCurrentUser ---');
      }
      currentUser = await _authRepository.getCurrentUser(
        accessToken: validAccessToken,
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
      // Handle token expiration - automatically refresh and retry
      // Only refresh on actual expiration errors, not "missing user_id" or other validation errors
      final messageLower = e.message.toLowerCase();
      final isTokenExpired = e.statusCode == 401 && 
          (messageLower.contains('expired') && !messageLower.contains('missing'));
      
      if (isTokenExpired) {
        if (kDebugMode) {
          print('🔄 Token expired, attempting to refresh...');
        }
        
        // Get SignInViewModel to refresh token
        final signInViewModel = context.read<SignInViewModel>();
        
        // Try to refresh the token
        final refreshed = await signInViewModel.refreshTokenSilently();
        
        if (refreshed && signInViewModel.accessToken != null) {
          if (kDebugMode) {
            print('✅ Token refreshed, retrying getCurrentUser...');
          }
          
          // Retry the request with new token
          try {
            // Ensure we have the latest token from SignInViewModel
            final refreshedAccessToken = signInViewModel.accessToken;
            if (refreshedAccessToken == null || refreshedAccessToken.isEmpty) {
              // Fallback: try loading from storage
              final tokenFromStorage = await TokenStorageService.getAccessToken();
              if (tokenFromStorage != null && tokenFromStorage.isNotEmpty) {
                if (kDebugMode) {
                  print('⚠️  Using token from storage for retry');
                }
                currentUser = await _authRepository.getCurrentUser(
                  accessToken: tokenFromStorage,
                  userId: userId,
                );
              } else {
                throw Exception('No access token available after refresh');
              }
            } else {
              currentUser = await _authRepository.getCurrentUser(
                accessToken: refreshedAccessToken,
                userId: userId,
              );
            }
            errorMessage = null; // Clear any previous errors on success
            
            if (kDebugMode) {
              print('✅ User loaded successfully after token refresh!');
              print('User ID: ${currentUser?.id}');
              print('Username: ${currentUser?.username}');
              print('Email: ${currentUser?.email}');
            }
          } on ApiException catch (retryError) {
            // If retry also fails with 401, don't retry again (avoid infinite loop)
            if (retryError.statusCode == 401) {
              if (kDebugMode) {
                print('❌ Retry failed with 401: ${retryError.message}');
                print('⚠️  This might indicate a backend issue with the refreshed token');
              }
              errorMessage = 'Session expired. Please login again.';
            } else {
              if (kDebugMode) {
                print('❌ Failed to load user after token refresh: ${retryError.message}');
              }
              errorMessage = 'Couldn\'t load your profile. Let\'s try refreshing!';
            }
            currentUser = null;
          } catch (retryError) {
            if (kDebugMode) {
              print('❌ Unexpected error during retry: $retryError');
            }
            errorMessage = 'Couldn\'t load your profile. Let\'s try refreshing!';
            currentUser = null;
          }
        } else {
          if (kDebugMode) {
            print('❌ Failed to refresh token');
          }
          errorMessage = 'Session expired. Please login again.';
          currentUser = null;
        }
      } else {
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
      }
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
