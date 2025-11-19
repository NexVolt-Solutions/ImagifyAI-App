import 'package:flutter/material.dart';
import 'package:genwalls/Model/utils/Routes/routes_name.dart';

class OnBoardingScreenViewModel extends ChangeNotifier {
  final PageController pageController = PageController();
  int currentPage = 0;

  final List<Map<String, dynamic>> text = [
    {
      'title': 'Create Stunning Wallpapers',
      'subtitle':
          'Create unique AI wallpapers from your\nideas, bringing imagination to your screen.',
      'buttonText': 'Next',
    },
    {
      'title': 'Personalize Your Screen',
      'subtitle':
          'Pick styles, colors, and resolutions to\ndesign wallpapers that match your vibe.',
      'buttonText': 'Continue',
    },
    {
      'title': 'One Tap to Set',
      'subtitle':
          'Preview and set your favorite wallpapers\ninstantly to refresh your phone’s look.',
      'buttonText': 'Start',
    },
  ];

  void onNextPressed(BuildContext context) {
    if (currentPage < 2) {
      currentPage++;
      pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    } else {
      Navigator.pushReplacementNamed(context, RoutesName.SignUpScreen);
    }
  }

  void onPageChanged(int index) {
    currentPage = index;
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
