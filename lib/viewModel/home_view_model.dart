import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/Core/utils/snackbar_util.dart';
import 'package:genwalls/models/wallpaper/suggest_response.dart';
import 'package:genwalls/models/wallpaper/wallpaper.dart';
import 'package:genwalls/repositories/wallpaper_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({WallpaperRepository? wallpaperRepository})
      : _wallpaperRepository = wallpaperRepository ?? WallpaperRepository();

  final WallpaperRepository _wallpaperRepository;

  final promptController = TextEditingController();
  final sizeController = TextEditingController(text: '1:1');
  final styleController = TextEditingController(text: 'default');
  final titleController = TextEditingController();
  final aiModelController = TextEditingController(text: 'default');
  bool isLoading = false;
  bool isCreating = false;
  String? suggestion;
  String? errorMessage;
  Wallpaper? createdWallpaper;

  int selectedIndex = 0;

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

  Future<void> fetchSuggestion(BuildContext context) async {
    if (isLoading) return;
    final prompt = promptController.text.trim();
    if (prompt.isEmpty) {
      _showMessage(context, 'Please enter a prompt');
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final SuggestResponse response =
          await _wallpaperRepository.suggestPrompt(prompt: prompt);
      suggestion = response.data?.toString() ?? response.message ?? 'No suggestion';
      _showMessage(context, response.message ?? 'Suggestion received', isError: false);
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
      _showMessage(context, 'Please enter a prompt');
      return;
    }

    final size = sizeController.text.trim().isNotEmpty ? sizeController.text.trim() : '1:1';
    final style =
        styleController.text.trim().isNotEmpty ? styleController.text.trim() : 'default';
    final title =
        titleController.text.trim().isNotEmpty ? titleController.text.trim() : prompt;
    final aiModel = aiModelController.text.trim().isNotEmpty
        ? aiModelController.text.trim()
        : 'default';

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
