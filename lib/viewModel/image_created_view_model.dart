import 'package:flutter/material.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/utils/snackbar_util.dart';
import 'package:genwalls/models/wallpaper/wallpaper.dart';
import 'package:genwalls/repositories/wallpaper_repository.dart';

class ImageCreatedViewModel extends ChangeNotifier {
  ImageCreatedViewModel({WallpaperRepository? wallpaperRepository})
      : _wallpaperRepository = wallpaperRepository ?? WallpaperRepository();

  final WallpaperRepository _wallpaperRepository;

  Wallpaper? wallpaper;
  bool isLoading = false;
  bool isDownloading = false;
  String? errorMessage;

  void setWallpaper(Wallpaper? data) {
    wallpaper = data;
    notifyListeners();
  }

  Future<void> recreate(BuildContext context) async {
    if (isLoading || wallpaper == null || wallpaper!.id.isEmpty) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      wallpaper = await _wallpaperRepository.recreateWallpaper(
        wallpaperId: wallpaper!.id,
      );
      _showMessage(context, 'Wallpaper recreated', isError: false);
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

  Future<void> download(BuildContext context) async {
    if (isDownloading || wallpaper == null || wallpaper!.id.isEmpty) return;

    isDownloading = true;
    errorMessage = null;
    notifyListeners();

    try {
      wallpaper = await _wallpaperRepository.downloadWallpaper(
        wallpaperId: wallpaper!.id,
      );
      _showMessage(context, 'Wallpaper downloaded', isError: false);
      // Add file-save handling here if needed; API currently returns metadata.
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      _showMessage(context, errorMessage!);
    } finally {
      isDownloading = false;
      notifyListeners();
    }
  }

  void _showMessage(BuildContext context, String message, {bool isError = true}) {
    SnackbarUtil.showTopSnackBar(context, message, isError: isError);
  }
}

