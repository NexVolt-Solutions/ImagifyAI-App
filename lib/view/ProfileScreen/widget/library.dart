import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/theme/theme_extensions.dart';
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
          backgroundColor: context.backgroundColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(AppAssets.starLogo, fit: BoxFit.cover),
                SvgPicture.asset(AppAssets.genWallsLogo, fit: BoxFit.cover),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).iconTheme.color,
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
                Text(
                  "Explore Prompt",
                  style: context.appTextStyles?.profileScreenTitle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.h(10)),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (items.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: context.h(40)),
                    child: Text(
                      'No wallpapers found.',
                      style: context.appTextStyles?.profileListItemTitle,
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
                              color: context.backgroundColor,
                              borderRadius: BorderRadius.circular(context.radius(12)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(context.radius(12)),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: context.surfaceColor,
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: context.subtitleColor,
                                          size: 40,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: context.surfaceColor,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: context.subtitleColor,
                                        size: 40,
                                      ),
                                    ),
                            ),
                          ),

                          SizedBox(height: context.h(8)),
                          Text(
                            item.title.isNotEmpty
                                ? item.title
                                : (item.prompt.isNotEmpty ? item.prompt : 'Wallpaper'),
                            style: context.appTextStyles?.profileCardTitle,
                            textAlign: TextAlign.center,
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
