import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Model/viewModel/bottom_nav_screen_view_model.dart';
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
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: bottomNavScreenViewModel
                .screens[bottomNavScreenViewModel.currentIndex],
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 64.h,
                  width: 350.w,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(56.r),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                                Image.asset(
                                  bottomNavScreenViewModel
                                      .bottomData[index]['image'],
                                  height: 30,
                                  width: 30,
                                  fit: BoxFit.cover,
                                  color:
                                      bottomNavScreenViewModel.currentIndex ==
                                          index
                                      ? Colors.purple
                                      : Colors.grey,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  bottomNavScreenViewModel
                                      .bottomData[index]['name'],
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    color:
                                        bottomNavScreenViewModel.currentIndex ==
                                            index
                                        ? Colors.purple
                                        : Colors.grey,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
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
          ),
        ],
      ),
    );
  }
}
