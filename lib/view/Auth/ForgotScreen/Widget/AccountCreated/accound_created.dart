import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';

class AccoundCreated extends StatelessWidget {
  const AccoundCreated({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: Scaffold(
        backgroundColor: AppColors.blackColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                  child: SvgPicture.asset(AppAssets.starLogo, fit: BoxFit.cover),
              ),
              SvgPicture.asset(AppAssets.genWallsLogo, fit: BoxFit.cover),
            ],
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: context.h(20)),
            children: [
              SizedBox(height: context.h(233)),
              Image.asset(
                AppAssets.tickIcon,
                height: context.h(100),
                width: context.w(100),
                fit: BoxFit.contain,
              ),
              SizedBox(height: context.h(24)),
              NormalText(
                crossAxisAlignment: CrossAxisAlignment.center,
                titleText: "You are all done!👏🏻",
                titleSize: context.text(20),
                titleWeight: FontWeight.w600,
                titleColor: AppColors.whiteColor,
                titleAlign: TextAlign.center,
              ),
              SizedBox(height: context.h(253)),
              CustomButton(
                onPressed: () {
                  Navigator.pushNamed(context, RoutesName.SignInScreen);
                },
                height: context.h(48),
                width: context.w(350),
                gradient: AppColors.gradient,
                text: 'Next',
                iconWidth: null,
                iconHeight: null,
                icon: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
