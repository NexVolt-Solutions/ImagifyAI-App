import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';

class OnBoardingScreenViewModel extends ChangeNotifier {
  int currentPage = 0;

  PageController mainController = PageController();
  PageController textController = PageController();

  List<Map<String, dynamic>> text = [
    {
      "image": AppAssets.imagIcon,
      "title": "Discover Amazing Wallpapers",
      "subtitle":
          "Explore a variety of stunning wallpapers for your home screen.",
      "buttonText": "Next",
    },
    {
      "image": AppAssets.onBoardingIcon,
      "title": "High Quality Collection",
      "subtitle":
          "Browse HD and 4K wallpapers that fit perfectly on your phone.",
      "buttonText": "Next",
    },
    {
      "image": AppAssets.imagIcon,
      "title": "Set Wallpapers Easily",
      "subtitle": "Apply wallpapers directly from the app with one tap.",
      "buttonText": "Get Started",
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
}
