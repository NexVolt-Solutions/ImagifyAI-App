import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/normal_text.dart';
import 'package:genwalls/Core/utils/snackbar_util.dart';
import 'package:genwalls/viewModel/library_view_model.dart';
import 'package:provider/provider.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryViewModel>().loadWallpapers(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryViewModel>(
      builder: (context, libraryViewModel, _) {
        final items = libraryViewModel.wallpapers;
        final isLoading = libraryViewModel.isLoading;
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
                  titleText: "Explore Prompt",
                  titleSize: context.text(20),
                  titleWeight: FontWeight.w600,
                  titleColor: AppColors.whiteColor,
                ),
                SizedBox(height: context.h(10)),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (items.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: context.h(40)),
                    child: Text(
                      'No wallpapers found.',
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: context.text(14),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: context.w(10),
                      mainAxisSpacing: context.h(10),
                      mainAxisExtent: context.h(340),
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final imageUrl =
                          (item.thumbnailUrl.isNotEmpty ? item.thumbnailUrl : item.imageUrl)
                              .trim();
                      return ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          Container(
                            padding: context.padAll(7),
                            decoration: BoxDecoration(
                              color: AppColors.blackColor,
                              borderRadius: BorderRadius.circular(context.radius(12)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(context.radius(12)),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Image.asset(
                                        AppAssets.conIcon,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      AppAssets.conIcon,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),

                          SizedBox(height: context.h(8)),
                          NormalText(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            titleText: item.title.isNotEmpty
                                ? item.title
                                : (item.prompt.isNotEmpty ? item.prompt : 'Wallpaper'),
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
                                  SnackbarUtil.showTopSnackBar(
                                    context,
                                    item.prompt.isNotEmpty ? item.prompt : 'No prompt',
                                    isError: false,
                                  );
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
      },
    );
  }
}
