import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_list_view.dart';
import 'package:genwalls/Core/CustomWidget/custom_textField.dart';
import 'package:genwalls/Core/CustomWidget/home_align.dart';
import 'package:genwalls/viewModel/bottom_nav_screen_view_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
                child: Image.asset(AppAssets.starLogo, fit: BoxFit.cover),
              ),
              Image.asset(AppAssets.genWallsLogo, fit: BoxFit.cover),
            ],
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: context.h(20)),
            children: [
              SizedBox(height: context.h(24)),
              ListTile(
                leading: Container(
                  height: context.h(50),
                  width: context.h(50),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  'Hello, Amna 👋',
                  style: GoogleFonts.poppins(
                    color: AppColors.whiteColor,
                    fontSize: context.text(20),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Ready to build your perfect wallpaper?',
                  style: GoogleFonts.poppins(
                    color: AppColors.textFieldIconColor,
                    fontSize: context.text(14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: context.h(24)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                child: CustomTextField(
                  validatorType: "name",
                  hintText: "Search Wallpapers... ",
                  borderRadius: context.radius(40),
                  prefixIcon: Icon(Icons.search),
                  iconColor: AppColors.whiteColor,
                ),
              ),
              SizedBox(height: context.h(19)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                child: DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    dashPattern: [10, 5],
                    strokeWidth: context.w(2),
                    radius: Radius.circular(context.radius(12)),
                    color: AppColors.whiteColor,
                  ),
                  child: Container(
                    height: context.h(318),
                    width: context.w(double.infinity),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.radius(12)),
                    ),
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                      children: [
                        SizedBox(height: context.h(20)),
                        Image.asset(
                          AppAssets.dotConIcon,
                          height: context.h(60),
                          width: context.w(60),
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: context.h(12)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.h(20),
                          ),
                          child: Text(
                            'Create Your Perfect Wallpaper',
                            style: GoogleFonts.poppins(
                              color: AppColors.whiteColor,
                              fontSize: context.text(20),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: context.h(12)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.h(8),
                          ),
                          child: Text(
                            'Use AI to generate stunning wallpapers tailored to your style. From abstract art to breathtaking landscapes.',
                            style: GoogleFonts.poppins(
                              color: AppColors.whiteColor,
                              fontSize: context.text(14),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: context.h(13)),
                        Align(
                          alignment: Alignment.center,
                          child: CustomButton(
                            onPressed: () {
                              final bottomNavProvider =
                                  Provider.of<BottomNavScreenViewModel>(
                                    context,
                                    listen: false,
                                  );

                              bottomNavProvider.currentIndex = 1;
                            },
                            height: context.h(47),
                            width: context.w(212),
                            iconWidth: null,
                            iconHeight: null,
                            icon: null,
                            gradient: AppColors.gradient,
                            text: 'Generate wallpaper',
                          ),
                        ),

                        SizedBox(height: context.h(13)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.h(20)),
              HomeAlign(text: 'Trending'),
              SizedBox(height: context.h(12)),
              CustomListView(image: AppAssets.conIcon),
              SizedBox(height: context.h(20)),
              HomeAlign(text: 'Nature'),
              SizedBox(height: context.h(12)),
              CustomListView(image: AppAssets.conIcon),
              SizedBox(height: context.h(20)),
              HomeAlign(text: '3D Render'),
              SizedBox(height: context.h(12)),
              CustomListView(image: AppAssets.conIcon),
              SizedBox(height: context.h(100)),
            ],
          ),
        ),
      ),
    );
  }
}
