// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Model/viewModel/on_boarding_screen_view_model.dart';
import 'package:genwalls/view/OnBoardingScreen/on_boarding_screen.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IndicatorScreen extends StatefulWidget {
  const IndicatorScreen({super.key});

  @override
  State<IndicatorScreen> createState() => _IndicatorScreenState();
}

class _IndicatorScreenState extends State<IndicatorScreen> {
  @override
  Widget build(BuildContext context) {
    final onBoardingViewModel = Provider.of<OnBoardingScreenViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: onBoardingViewModel.pageController,
            children: const [OnboardingScreen()],
          ),
          Positioned(
            bottom: 105.h,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: onBoardingViewModel.pageController,
                count: 3,
                effect: ExpandingDotsEffect(
                  activeDotColor: Colors.purple,
                  dotColor: Colors.grey,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
