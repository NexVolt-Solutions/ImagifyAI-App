import 'package:flutter/material.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/utils/snackbar_util.dart';
import 'package:genwalls/models/wallpaper/wallpaper.dart';
import 'package:genwalls/repositories/wallpaper_repository.dart';
import 'package:genwalls/viewModel/sign_in_view_model.dart';
import 'package:provider/provider.dart';

class LibraryViewModel extends ChangeNotifier {
  LibraryViewModel({WallpaperRepository? wallpaperRepository})
      : _wallpaperRepository = wallpaperRepository ?? WallpaperRepository();

  final WallpaperRepository _wallpaperRepository;

  bool isLoading = false;
  String? errorMessage;
  List<Wallpaper> wallpapers = [];

  Future<void> loadWallpapers(BuildContext context) async {
    if (isLoading) return;

    // Get access token from SignInViewModel
    final signInViewModel = context.read<SignInViewModel>();
    final accessToken = signInViewModel.accessToken;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (accessToken == null || accessToken.isEmpty) {
        throw ApiException('Access token is required. Please login again.');
      }
      
      wallpapers = await _wallpaperRepository.fetchWallpapers(accessToken: accessToken);
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

  void _showMessage(BuildContext context, String message, {bool isError = true}) {
    SnackbarUtil.showTopSnackBar(context, message, isError: isError);
  }
}

