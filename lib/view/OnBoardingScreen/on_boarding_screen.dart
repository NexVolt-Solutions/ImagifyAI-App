import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
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

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(context.h(64)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.h(20)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(AppAssets.starLogo),

              SvgPicture.asset(AppAssets.genWallsLogo),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: context.h(20)),
            SizedBox(
              height: context.h(410),
              width: double.infinity,
              child: PageView.builder(
                controller: viewModel.mainController,
                physics: const BouncingScrollPhysics(),
                itemCount: viewModel.text.length,
                itemBuilder: (context, index) {
                  final data = viewModel.text[index];
                  return Image.asset(data['image']);
                },
              ),
            ),

            SizedBox(height: context.h(66)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                SmoothPageIndicator(
                  controller: viewModel.mainController,
                  count: viewModel.text.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.whiteColor,
                    dotColor: AppColors.primeryColor,
                    dotHeight: 10,
                    dotWidth: 10,
                    expansionFactor: 3,
                    spacing: 8,
                  ),
                ),
                SizedBox(width: context.w(111)),
                GestureDetector(
                  onTap: () async {
                    if (viewModel.currentPage < viewModel.text.length - 1) {
                      viewModel.mainController.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // Mark onboarding as completed when "Done" is clicked
                      await viewModel.completeOnboarding();
                      Navigator.pushReplacementNamed(
                        context,
                        RoutesName.SignInScreen,
                      );
                    }
                  },
                  child: NormalText(
                    titleText:
                        viewModel.text[viewModel.currentPage]['buttonText'] ??
                        '',
                    titleSize: context.text(16),
                    titleWeight: FontWeight.w500,
                    titleColor: AppColors.whiteColor,
                  ),
                ),
                SizedBox(width: context.w(20)),
              ],
            ),
            SizedBox(height: context.h(45)),
          ],
        ),
      ),
    );
  }
}
