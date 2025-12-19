import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/viewModel/bottom_nav_screen_view_model.dart';
import 'package:provider/provider.dart';

class BottomNavScreen extends StatefulWidget {
  final int selectedIndex;
  const BottomNavScreen({super.key, this.selectedIndex = 0});
  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the bottom nav index if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bottomNavScreenViewModel = Provider.of<BottomNavScreenViewModel>(
        context,
        listen: false,
      );
      if (widget.selectedIndex != bottomNavScreenViewModel.currentIndex) {
        bottomNavScreenViewModel.updateIndex(widget.selectedIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavScreenViewModel = Provider.of<BottomNavScreenViewModel>(
      context,
    );

    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: Container(
          color: AppColors.blackColor,
          child: Align(
            alignment: Alignment.center,
            child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(AppAssets.starLogo, fit: BoxFit.cover),
                        SvgPicture.asset(AppAssets.genWallsLogo, fit: BoxFit.cover),
                      ],
                    ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            /// MAIN SCREEN
            bottomNavScreenViewModel.screens[bottomNavScreenViewModel
                .currentIndex],

            /// BOTTOM NAV BAR
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                                 margin:  EdgeInsets.symmetric(
                    horizontal: context.w(20),
                    vertical: context.h(20),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(16),
                    vertical: context.h(11),
                  ),
                    decoration: BoxDecoration(
                      color: AppColors.bottomBarColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(context.radius(68)),
                        topLeft: Radius.circular(context.radius(68)),
                        bottomLeft: Radius.circular(context.radius(56)),
                        bottomRight: Radius.circular(context.radius(56)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        bottomNavScreenViewModel.bottomData.length,
                        (index) {
                          return InkWell(
                            onTap: () =>
                                bottomNavScreenViewModel.updateIndex(index),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                bottomNavScreenViewModel.currentIndex == index
                                    ? ShaderMask(
                                        shaderCallback: (bounds) => AppColors
                                            .gradient
                                            .createShader(bounds),
                                        blendMode: BlendMode.srcIn,
                                        child: Image.asset(
                                          bottomNavScreenViewModel
                                              .bottomData[index]['image'],
                                        
                                        ),
                                      )
                                    : Image.asset(
                                        bottomNavScreenViewModel
                                            .bottomData[index]['image'],
                                
                                        color: AppColors.bottomBarIconColor,
                                      ),
                                SizedBox(height: context.h(4)),
                                Text(
                                  bottomNavScreenViewModel
                                      .bottomData[index]['name'],
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    color:
                                        bottomNavScreenViewModel.currentIndex ==
                                            index
                                        ? AppColors.primeryColor
                                        : AppColors.bottomBarIconColor,
                                    fontSize: context.text(10),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
