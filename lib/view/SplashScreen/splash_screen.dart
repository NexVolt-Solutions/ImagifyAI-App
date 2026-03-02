import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/splash_screen_view_model.dart';

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
      backgroundColor: context.backgroundColor,
      body: Center(
        child: SvgPicture.asset(
          AppAssets.imagifyaiLogo,
          fit: BoxFit.cover,
          height: context.h(80),
          width: context.w(80),
        ),
      ),
    );
  }
}
