import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';

class ImageCreatedScreen extends StatefulWidget {
  const ImageCreatedScreen({super.key});

  @override
  State<ImageCreatedScreen> createState() => _ImageCreatedScreenState();
}

class _ImageCreatedScreenState extends State<ImageCreatedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(AppAssets.starLogo, fit: BoxFit.cover),
            Image.asset(AppAssets.genWallsLogo, fit: BoxFit.cover),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: context.padSym(h: 20),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 24,
                    color: AppColors.whiteColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: context.padSym(h: 20),
          children: [
            NormalText(
              titleText: "Result",
              titleSize: context.text(16),
              titleWeight: FontWeight.w500,
              titleColor: AppColors.whiteColor,
              titleAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(20)),
            Container(
              height: context.h(410),
              width: context.w(350),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(context.radius(12)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.radius(12)),
                child: Image.asset(AppAssets.conIcon, fit: BoxFit.fill),
              ),
            ),
            SizedBox(height: context.h(20)),
            Container(
              padding: context.padAll(20),
              decoration: BoxDecoration(
                color: Color(0xFF17171D),
                borderRadius: BorderRadius.circular(context.radius(12)),
              ),
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: context.h(20)),
                    child: NormalText(
                      titleText:
                          '3D cartoon-style illustration of a young girl with Día de los Muertos face paint, wearing casual clothes, standing in a glowing.',
                      titleSize: context.text(14),
                      titleWeight: FontWeight.w500,
                      titleColor: AppColors.whiteColor,
                      titleAlign: TextAlign.center,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: context.padSym(h: 20),
                      child: Image.asset(AppAssets.copyIcon, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.h(31)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  onPressed: () {},
                  height: context.h(48),
                  width: context.w(165),
                  iconHeight: 24,
                  iconWidth: 24,
                  gradient: AppColors.gradient,
                  text: 'Recreate',
                  icon: AppAssets.reCreateIcon,
                ),
                CustomButton(
                  onPressed: () {},
                  height: context.h(48),
                  width: context.w(165),
                  iconHeight: 24,
                  iconWidth: 24,
                  gradient: AppColors.gradient,
                  text: 'Download',
                  icon: AppAssets.downloadIcon,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
