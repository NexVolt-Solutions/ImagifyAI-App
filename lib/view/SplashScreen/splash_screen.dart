import 'package:flutter/material.dart';
import 'package:imagifyai/viewModel/splash_screen_view_model.dart';

/// Minimal entry screen: black only so it matches the native splash.
/// Navigation logic runs in SplashScreenViewModel (onboarding / sign in / home).
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
    return const Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.shrink(),
    );
  }
}
