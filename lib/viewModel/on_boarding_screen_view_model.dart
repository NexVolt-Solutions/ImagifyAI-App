import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/services/token_storage_service.dart';

class OnBoardingScreenViewModel extends ChangeNotifier {
  int currentPage = 0;

  PageController mainController = PageController();
  PageController textController = PageController();

  List<Map<String, dynamic>> text = [
    {
      "image": AppAssets.onBoardingIcon1,
      "title": "Create Stunning Wallpapers",
      "subtitle":
          "Explore a variety of stunning wallpapers for your home screen.",
      "buttonText": "Next",
    },
    {
      "image": AppAssets.onBoardingIcon2,
      "title": "Personalize Your Screen",
      "subtitle":
          "Browse HD and 4K wallpapers that fit perfectly on your phone.",
      "buttonText": "Next",
    },
    {
      "image": AppAssets.onBoardingIcon3,
      "title": "One Tap to Set",
      "subtitle": "Apply wallpapers directly from the app with one tap.",
      "buttonText": "Done",
    },
  ];

  bool _isSyncing = false;

  OnBoardingScreenViewModel() {
    mainController.addListener(() {
      if (!_isSyncing && textController.hasClients) {
        final mainPage = mainController.page?.round() ?? 0;
        final textPage = textController.page?.round() ?? 0;
        if (mainPage != textPage) {
          _isSyncing = true;
          textController.jumpToPage(mainPage);
          updatePage(mainPage);
          _isSyncing = false;
        }
      }
    });

    textController.addListener(() {
      if (!_isSyncing && mainController.hasClients) {
        final textPage = textController.page?.round() ?? 0;
        final mainPage = mainController.page?.round() ?? 0;
        if (textPage != mainPage) {
          _isSyncing = true;
          mainController.jumpToPage(textPage);
          updatePage(textPage);
          _isSyncing = false;
        }
      }
    });
  }

  void updatePage(int page) {
    currentPage = page;
    notifyListeners();
  }

  /// Mark onboarding as completed and save to storage
  Future<void> completeOnboarding() async {
    try {
      final saved = await TokenStorageService.setOnboardingCompleted(true);
      if (kDebugMode) {
        if (saved) {
          print('✅ Onboarding marked as completed');
        } else {
          print('❌ Failed to save onboarding completion status');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error completing onboarding: $e');
      }
    }
  }
}
