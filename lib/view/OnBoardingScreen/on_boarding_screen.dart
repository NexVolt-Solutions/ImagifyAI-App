import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/viewModel/on_boarding_screen_view_model.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<OnBoardingScreenViewModel>(context);

    final currentData = viewModel.text[viewModel.currentPage];

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
          text: currentData['buttonText'],
          iconWidth: null,
          iconHeight: null,
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
        preferredSize: const Size.fromHeight(64),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(AppAssets.starLogo, fit: BoxFit.cover),
            Image.asset(AppAssets.genWallsLogo, fit: BoxFit.cover),
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
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: context.h(520),
              child: PageView.builder(
                controller: viewModel.mainController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  viewModel.updatePage(index);
                  if (viewModel.textController.hasClients) {
                    viewModel.textController.jumpToPage(index);
                  }
                },

                itemCount: viewModel.text.length,
                itemBuilder: (context, index) {
                  final data = viewModel.text[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(20)),
                    child: Image.asset(data['image'], fit: BoxFit.cover),
                  );
                },
              ),
            ),
            SizedBox(height: context.h(40)),
            Expanded(
              child: PageView.builder(
                controller: viewModel.mainController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  viewModel.updatePage(index);
                  if (viewModel.textController.hasClients) {
                    viewModel.textController.jumpToPage(index);
                  }
                },

                itemCount: viewModel.text.length,
                itemBuilder: (context, index) {
                  final data = viewModel.text[index];
                  return Column(
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
                      SizedBox(height: context.h(25)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(viewModel.text.length, (
                          dotIndex,
                        ) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            width: viewModel.currentPage == dotIndex ? 12 : 8,
                            height: viewModel.currentPage == dotIndex ? 12 : 8,
                            decoration: BoxDecoration(
                              color: viewModel.currentPage == dotIndex
                                  ? AppColors.whiteColor
                                  : Colors.white54,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
