import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';
import 'package:genwalls/models/wallpaper/wallpaper.dart';
import 'package:genwalls/viewModel/image_created_view_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ImageCreatedScreen extends StatefulWidget {
  const ImageCreatedScreen({super.key});

  @override
  State<ImageCreatedScreen> createState() => _ImageCreatedScreenState();
}

class _ImageCreatedScreenState extends State<ImageCreatedScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Wallpaper) {
      context.read<ImageCreatedViewModel>().setWallpaper(args);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageCreatedViewModel>(
      builder: (context, imageCreatedViewModel, _) {
        final wp = imageCreatedViewModel.wallpaper;
        final imageUrl = wp?.imageUrl ?? '';
        final promptText = wp?.prompt ??
            '3D cartoon-style illustration of a young girl with Día de los Muertos face paint, wearing casual clothes, standing in a glowing.';

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
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.fill,
                            errorBuilder: (_, __, ___) =>
                                Image.asset(AppAssets.conIcon, fit: BoxFit.fill),
                          )
                        : Image.asset(AppAssets.conIcon, fit: BoxFit.fill),
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
                        child: Text(
                          promptText,
                          style: GoogleFonts.poppins(
                            color: AppColors.whiteColor,
                            fontSize: context.text(14),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
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
                      onPressed: imageCreatedViewModel.isLoading
                          ? null
                          : () => imageCreatedViewModel.recreate(context),
                      height: context.h(48),
                      width: context.w(165),
                      iconHeight: 24,
                      iconWidth: 24,
                      gradient: AppColors.gradient,
                      text: imageCreatedViewModel.isLoading ? 'Please wait...' : 'Recreate',
                      icon: AppAssets.reCreateIcon,
                    ),
                    CustomButton(
                      onPressed: imageCreatedViewModel.isDownloading
                          ? null
                          : () => imageCreatedViewModel.download(context),
                      height: context.h(48),
                      width: context.w(165),
                      iconHeight: 24,
                      iconWidth: 24,
                      gradient: AppColors.gradient,
                      text: imageCreatedViewModel.isDownloading
                          ? 'Please wait...'
                          : 'Download',
                      icon: AppAssets.downloadIcon,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
