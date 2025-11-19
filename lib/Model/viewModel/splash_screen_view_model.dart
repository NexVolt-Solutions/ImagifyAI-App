import 'package:flutter/material.dart';
import 'package:genwalls/Model/utils/Routes/routes_name.dart';

class SplashScreenViewModel extends ChangeNotifier {
  void splashService(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, RoutesName.IndicatorScreen);
    });
  }
}
