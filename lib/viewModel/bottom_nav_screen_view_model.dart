import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/view/Home/home.dart';
import 'package:genwalls/view/ImageGenerate/image_generate_screen.dart';
import 'package:genwalls/view/ProfileScreen/profile_screen.dart';

class BottomNavScreenViewModel extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  set currentIndex(int value) {
    _currentIndex = value;
    notifyListeners();
  }

  List<Map<String, dynamic>> bottomData = [
    {'name': 'Home', 'image': AppAssets.homeIcon},
    {'name': 'Create Image', 'image': AppAssets.imageIcon},
    {'name': 'Profile', 'image': AppAssets.bottomProfileIcon},
  ];

  List<Widget> screens = [Home(), ImageGenerateScreen(), ProfileScreen()];
}
