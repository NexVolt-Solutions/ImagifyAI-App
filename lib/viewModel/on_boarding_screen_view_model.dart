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

  OnBoardingScreenViewModel() {
    mainController.addListener(() {
      if (textController.hasClients &&
          textController.page != mainController.page) {
        textController.jumpTo(mainController.position.pixels);
      }
    });
  }

  void updatePage(int page) {
    currentPage = page;
    notifyListeners();
  }
}
