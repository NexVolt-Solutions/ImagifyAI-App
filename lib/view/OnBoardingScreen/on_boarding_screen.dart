
import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/viewModel/on_boarding_screen_view_model.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<OnBoardingScreenViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.blackColor,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: context.h(43),
          left: context.w(20),
          right: context.w(20),
        ),
        child: CustomButton(
          height: context.h(45),
          width: context.w(300),
          gradient: AppColors.gradient,
          text: viewModel.text[viewModel.currentPage]['buttonText'],
          icon: null,
          onPressed: () {
            if (viewModel.currentPage < viewModel.text.length - 1) {
              viewModel.mainController.nextPage(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
              );
            } else {
              Navigator.pushReplacementNamed(context, RoutesName.SignUpScreen);
            }
          },
        ),
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(context.h(100)),
        child: Padding( 
          padding: EdgeInsets.symmetric(vertical: context.h(20)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(AppAssets.genWallsLogo, fit: BoxFit.cover),              Image.asset(AppAssets.starLogo, fit: BoxFit.cover),
              Image.asset(AppAssets.starLogo, fit: BoxFit.cover),

              Positioned(
                right: 20,
                top: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      RoutesName.SignUpScreen,
                    );
                  },
                  child: NormalText(
                    titleText: "Skip",
                    titleSize: context.text(16),
                    titleWeight: FontWeight.w500,
                    titleColor: AppColors.whiteColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: context.h(410),
              width: double.infinity,
              child: PageView.builder(
                controller: viewModel.mainController,
                physics: const BouncingScrollPhysics(),
                itemCount: viewModel.text.length,
                itemBuilder: (context, index) {
                  final data = viewModel.text[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(20)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(context.radius(16)),
                      child: SizedBox(
                        height: context.h(410),
                        width: context.w(350),
                        child: Image.asset(
                          data['image'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: context.h(40)),
            Expanded(
              child: PageView.builder(
                controller: viewModel.textController,
                physics: const BouncingScrollPhysics(),
                itemCount: viewModel.text.length,
                onPageChanged: (index) {
                  viewModel.updatePage(index);
                  viewModel.mainController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                itemBuilder: (context, index) {
                  final data = viewModel.text[index];
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          data['title'],
                          style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: context.text(22),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.h(10)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.w(25),
                          ),
                          child: Text(
                            data['subtitle'],
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: context.text(16),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: context.h(25)),
            SmoothPageIndicator(
              controller: viewModel.mainController,
              count: viewModel.text.length,
              effect: ExpandingDotsEffect(
                activeDotColor: AppColors.whiteColor,
                dotColor: Colors.white54,
                dotHeight: 10,
                dotWidth: 10,
                expansionFactor: 3,
                spacing: 8,
              ),
            ),
            SizedBox(height: context.h(20)),
          ],
        ),
      ),
    );
  }
}
