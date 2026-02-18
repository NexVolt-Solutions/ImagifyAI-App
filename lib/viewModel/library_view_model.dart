import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/Core/services/token_storage_service.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:imagifyai/models/wallpaper/wallpaper.dart';
import 'package:imagifyai/repositories/wallpaper_repository.dart';
import 'package:imagifyai/viewModel/sign_in_view_model.dart';
import 'package:provider/provider.dart';

class LibraryViewModel extends ChangeNotifier {
  LibraryViewModel({WallpaperRepository? wallpaperRepository})
    : _wallpaperRepository = wallpaperRepository ?? WallpaperRepository();

  final WallpaperRepository _wallpaperRepository;

  bool isLoading = false;
  bool isLoadingMore = false;
  String? errorMessage;
  List<Wallpaper> wallpapers = [];
  int currentPage = 1;
  int limit = 10; // Number of items per page (updated to 10)
  bool hasMorePages = true;

  /// Load wallpapers (first page or refresh)
  Future<void> loadWallpapers(
    BuildContext context, {
    bool refresh = false,
  }) async {
    if (isLoading) return;

    // Get access token from SignInViewModel or storage
    final signInViewModel = context.read<SignInViewModel>();
    String? accessToken = signInViewModel.accessToken;

    // If not available in SignInViewModel, try loading from storage
    if (accessToken == null || accessToken.isEmpty) {
      if (kDebugMode) {
        print(
          '⚠️  SignInViewModel token not available, trying to load from storage...',
        );
      }
      try {
        accessToken = await TokenStorageService.getAccessToken();
      } catch (e) {
        if (kDebugMode) {
          print('❌ Failed to load token from storage: $e');
        }
      }
    }

    if (accessToken == null || accessToken.isEmpty) {
      errorMessage = 'Access token is required. Please login again.';
      _showMessage(context, errorMessage!);
      return;
    }

    isLoading = true;
    errorMessage = null;
    if (refresh) {
      wallpapers.clear();
      currentPage = 1;
      hasMorePages = true;
    }
    notifyListeners();

    try {
      final fetchedWallpapers = await _wallpaperRepository.fetchWallpapers(
        accessToken: accessToken,
        page: 1,
        limit: limit,
      );

      wallpapers = fetchedWallpapers;
      currentPage = 1;
      hasMorePages = fetchedWallpapers.length >= limit;

      if (kDebugMode) {
        print('✅ Wallpapers loaded: ${wallpapers.length}');
        print('Has more pages: $hasMorePages');
      }
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading wallpapers: $e');
      }
      errorMessage = 'Something went wrong. Please try again.';
      _showMessage(context, errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load more wallpapers (pagination)
  Future<void> loadMoreWallpapers(BuildContext context) async {
    if (isLoadingMore || !hasMorePages) return;

    // Get access token from SignInViewModel or storage
    final signInViewModel = context.read<SignInViewModel>();
    String? accessToken = signInViewModel.accessToken;

    // If not available in SignInViewModel, try loading from storage
    if (accessToken == null || accessToken.isEmpty) {
      try {
        accessToken = await TokenStorageService.getAccessToken();
      } catch (e) {
        if (kDebugMode) {
          print('❌ Failed to load token from storage: $e');
        }
      }
    }

    if (accessToken == null || accessToken.isEmpty) {
      if (kDebugMode) {
        print('⚠️  No access token available for loading more wallpapers');
      }
      return;
    }

    isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = currentPage + 1;
      final fetchedWallpapers = await _wallpaperRepository.fetchWallpapers(
        accessToken: accessToken,
        page: nextPage,
        limit: limit,
      );

      if (fetchedWallpapers.isNotEmpty) {
        wallpapers.addAll(fetchedWallpapers);
        currentPage = nextPage;
        hasMorePages = fetchedWallpapers.length >= limit;

        if (kDebugMode) {
          print('✅ More wallpapers loaded: ${fetchedWallpapers.length}');
          print('Total wallpapers: ${wallpapers.length}');
          print('Current page: $currentPage');
          print('Has more pages: $hasMorePages');
        }
      } else {
        hasMorePages = false;
        if (kDebugMode) {
          print('✅ No more wallpapers to load');
        }
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('❌ Error loading more wallpapers: ${e.message}');
      }
      // Don't show error to user for load more failures
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error loading more wallpapers: $e');
      }
      // Don't show error to user for load more failures
    } finally {
      isLoadingMore = false;
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
}
