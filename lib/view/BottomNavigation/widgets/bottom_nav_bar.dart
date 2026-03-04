import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';

class BottomNavBar extends StatelessWidget {
  final List<Map<String, dynamic>> bottomData;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.bottomData,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: context.w(20),
          vertical: context.h(20),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.w(16),
          vertical: context.h(11),
        ),
        decoration: BoxDecoration(
          color: context.theme.bottomNavigationBarTheme.backgroundColor,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(context.radius(68)),
            topLeft: Radius.circular(context.radius(68)),
            bottomLeft: Radius.circular(context.radius(56)),
            bottomRight: Radius.circular(context.radius(56)),
          ),
          border: Border.all(
            color: context.theme.brightness == Brightness.dark
                ? context.backgroundColor
                : context.primaryColor,
            width: context.w(1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(bottomData.length, (index) {
            final isSelected = currentIndex == index;
            return GestureDetector(
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  isSelected
                      ? ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.gradient.createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: Image.asset(bottomData[index]['image']),
                        )
                      : Image.asset(
                          bottomData[index]['image'],
                          color: context
                              .theme
                              .bottomNavigationBarTheme
                              .unselectedItemColor,
                        ),
                  SizedBox(height: context.h(4)),
                  Text(
                    bottomData[index]['name'],
                    style: isSelected
                        ? context.appTextStyles?.bottomNavLabelSelected
                        : context.appTextStyles?.bottomNavLabelUnselected,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
