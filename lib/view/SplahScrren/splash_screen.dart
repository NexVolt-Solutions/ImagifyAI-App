import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Model/viewModel/splash_screen_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashScreenViewModel _splashScreenViewModel = SplashScreenViewModel();

  @override
  void initState() {
    super.initState();
    _splashScreenViewModel.splashService(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Image.asset(AppAssets.splashLogo)),
    );
  }
}
