import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    final bottomNavScreenViewModel = Provider.of<BottomNavScreenViewModel>(
      context,
    );
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: bottomNavScreenViewModel
                .screens[bottomNavScreenViewModel.currentIndex],
          ),
          Positioned(
            bottom: context.h(47),
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                child: Container(
                  height: context.h(64),
                  width: context.w(350),
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
                          onTap: () {
                            setState(() {
                              bottomNavScreenViewModel.currentIndex = index;
                            });
                          },
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
                                        height: context.h(18),
                                        width: context.w(18),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      bottomNavScreenViewModel
                                          .bottomData[index]['image'],
                                      height: context.h(18),
                                      width: context.w(18),
                                      fit: BoxFit.contain,
                                      color: AppColors.textFieldIconColor,
                                    ),
                              SizedBox(height: context.h(4)),
                              bottomNavScreenViewModel.currentIndex == index
                                  ? ShaderMask(
                                      shaderCallback: (bounds) => AppColors
                                          .gradient
                                          .createShader(bounds),
                                      blendMode: BlendMode.srcIn,
                                      child: Text(
                                        bottomNavScreenViewModel
                                            .bottomData[index]['name'],
                                        style: TextStyle(
                                          fontFamily: 'Manrope',
                                          color: Colors
                                              .white, // important (masked)
                                          fontSize: context.text(10),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      bottomNavScreenViewModel
                                          .bottomData[index]['name'],
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        color: Colors.grey,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
