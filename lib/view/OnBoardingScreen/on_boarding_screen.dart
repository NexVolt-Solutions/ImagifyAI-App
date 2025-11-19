import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Model/utils/Routes/routes_name.dart';
import 'package:genwalls/Model/viewModel/on_boarding_screen_view_model.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final onBoardingViewModel = Provider.of<OnBoardingScreenViewModel>(context);
    final text = onBoardingViewModel.text[onBoardingViewModel.currentPage];

    return Scaffold(
      body: Container(
        height: double.infinity.h,
        width: double.infinity.w,
        color: Colors.black,
        child: Stack(
          children: [
            Positioned(
              top: 30.h,
              left: 0.w,
              right: 0.w,
              child: Center(
                child: Image.asset(AppAssets.starLogo, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 30.h,
              left: 0.w,
              right: 0.w,
              child: Center(
                child: Image.asset(
                  AppAssets.genWallsLogo,
                  height: 20.h,
                  width: 120.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 10.h,
              right: 2.w,
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacementNamed(
                    context,
                    RoutesName.SignUpScreen,
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 30.0.w, top: 20.0.h),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0.w,
              left: 0.w,
              bottom: 170.h,
              child: Center(
                child: Text(
                  text['title'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0.w,
              left: 0.w,
              bottom: 130.h,
              child: Center(
                child: Text(
                  text['subtitle'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontStyle: FontStyle.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Positioned(
              right: 0.w,
              left: 0.w,
              bottom: 50.h,
              child: Center(
                child: CustomButton(
                  onPressed: () {
                    onBoardingViewModel.onNextPressed(context);
                  },
                  height: 40.h,
                  width: 300.w,
                  text: text['buttonText'],
                  icon: null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
