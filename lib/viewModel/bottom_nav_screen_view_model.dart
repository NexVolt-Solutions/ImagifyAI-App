import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/view/Home/home.dart';
import 'package:imagifyai/view/ImageGenerate/image_generate_screen.dart';
import 'package:imagifyai/view/ProfileScreen/profile_screen.dart';

class BottomNavScreenViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void updateIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  List<Map<String, dynamic>> bottomData = [
    {'name': 'Home', 'image': AppAssets.homeIcon},
    {'name': 'Create Image', 'image': AppAssets.imageIcon},
    {'name': 'Profile', 'image': AppAssets.bottomProfileIcon},
  ];

  List<Widget> screens = [Home(), ImageGenerateScreen(), ProfileScreen()];
}
