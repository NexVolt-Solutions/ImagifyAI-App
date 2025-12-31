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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryViewModel>().loadWallpapers(context);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    // Load more when user scrolls to 80% of the list
    if (currentScroll >= maxScroll * 0.8) {
      final libraryViewModel = context.read<LibraryViewModel>();
      if (!libraryViewModel.isLoadingMore && libraryViewModel.hasMorePages) {
        libraryViewModel.loadMoreWallpapers(context);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryViewModel>(
      builder: (context, libraryViewModel, _) {
        final items = libraryViewModel.wallpapers;
        final isLoading = libraryViewModel.isLoading;
        return Scaffold(
          backgroundColor: context.backgroundColor,
            //with arrow 
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(65),

            child: Align(
              alignment: Alignment.bottomCenter,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(AppAssets.starLogo, fit: BoxFit.cover),
                  SvgPicture.asset(AppAssets.genWallsLogo, fit: BoxFit.cover),
                  Positioned(
                    left: 0,
                     child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).iconTheme.color,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
            body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await libraryViewModel.loadWallpapers(context, refresh: true);
              },
              child: ListView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                children: [
                Align(
                    alignment: Alignment.topLeft,
                  child: Text(
                    "Explore Prompt",
                    style: context.appTextStyles?.profileScreenTitle,
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(height: context.h(10)),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: context.w(10),
                      mainAxisSpacing: context.h(10),
                      mainAxisExtent: context.h(200),
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final imageUrl =
                          (item.thumbnailUrl.isNotEmpty ? item.thumbnailUrl : item.imageUrl)
                              .trim();
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
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
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            color: context.surfaceColor,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                        loadingProgress.expectedTotalBytes!
                                                    : null,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          );
                                        },
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
                          ),
                          SizedBox(height: context.h(8)),
                          Text(
                            item.title.isNotEmpty
                                ? item.title
                                : (item.prompt.isNotEmpty ? item.prompt : 'Wallpaper'),
                            style: context.appTextStyles?.profileCardTitle,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: context.h(6)),
                          CustomButton(
                            height: context.h(24),
                            width: context.w(130),
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
                        ],
                      );
                    },
                  ),
                  // Load more indicator
                  if (libraryViewModel.isLoadingMore)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: context.h(20)),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                 
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
