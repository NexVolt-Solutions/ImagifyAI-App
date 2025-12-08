import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
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
                padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back_ios,
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
          padding: EdgeInsets.symmetric(horizontal: context.h(20)),
          children: [
            NormalText(
              crossAxisAlignment: CrossAxisAlignment.center,
              titleText: "Privacy Policy",
              titleSize: context.text(20),
              titleWeight: FontWeight.w600,
              titleColor: AppColors.whiteColor,
            ),
            SizedBox(height: context.h(10)),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 9,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: context.w(10),
                mainAxisSpacing: context.h(10),
                mainAxisExtent: context.h(340),
              ),
              itemBuilder: (context, index) {
                return ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Container(
                      padding: context.padAll(7),
                      decoration: BoxDecoration(
                        color: AppColors.blackColor,
                        borderRadius: BorderRadius.circular(context.radius(12)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(context.radius(12)),
                        child: Image.asset(
                          AppAssets.conIcon,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    SizedBox(height: context.h(8)),
                    NormalText(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      titleText: "A Majestic Iron Bird That Stands Guard",
                      titleSize: context.text(11),
                      titleWeight: FontWeight.w700,
                      titleColor: AppColors.whiteColor,
                      titleAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.h(6)),
                    SizedBox(
                      child: Align(
                        alignment: Alignment.center,
                        child: CustomButton(
                          height: context.h(25),
                          width: context.w(116),
                          fontSize: context.text(11),
                          gradient: AppColors.gradient,
                          text: "Use This Prompt",
                          onPressed: () {
                            print("Button working!");
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
