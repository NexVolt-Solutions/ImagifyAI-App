import 'package:flutter/widgets.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Model/utils/Routes/routes_name.dart';

class HomeViewModel extends ChangeNotifier {
  int selectedIndex = 0;

  List<Map<String, dynamic>> bottomData = [
    {'name': 'Home', 'image': AppAssets.homeIcon},
    {'name': 'Create Image', 'image': AppAssets.imageIcon},
    {'name': 'My Profile', 'image': AppAssets.profileIcon},
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
}
