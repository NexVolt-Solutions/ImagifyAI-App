import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/app_loading_indicator.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_list_view.dart';
import 'package:genwalls/Core/CustomWidget/home_align.dart';
import 'package:genwalls/Core/theme/theme_extensions.dart';
import 'package:genwalls/models/user/user.dart';
import 'package:genwalls/view/CategoryDetails/category_details_screen.dart';
import 'package:genwalls/viewModel/home_view_model.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _hasLoaded = false;

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: context.h(50),
      width: context.h(50),
      decoration: BoxDecoration(
        color: context.subtitleColor.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: context.h(30),
        color: context.textColor.withOpacity(0.7),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoaded) return;
    _hasLoaded = true;

    final homeViewModel = context.read<HomeViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (kDebugMode) {
          print('✅ Starting parallel data loading...');
        }
        // Load all data in parallel for faster loading
        homeViewModel.loadCurrentUser(context);
        homeViewModel.loadStyles(context);
        homeViewModel.loadGroupedWallpapers(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, homeViewModel, _) {
        return Scaffold(
          backgroundColor: context.backgroundColor,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await homeViewModel.refreshHomeData(context);
              },
              child: CustomScrollView(
                slivers: [
                // User Profile Section - Pinned
                SliverPersistentHeader(
                  // floating: true,
                  pinned: true,
                  delegate: _UserProfileHeaderDelegate(
                    height: 65.0,
                    child: ListTile(
                      contentPadding: EdgeInsets.only(left: context.w(20)),
                      leading: ClipOval(
                        child:
                            homeViewModel.currentUser?.profileImageUrl !=
                                    null &&
                                homeViewModel
                                    .currentUser!
                                    .profileImageUrl!
                                    .isNotEmpty
                            ? Image.network(
                                homeViewModel.currentUser!.profileImageUrl!,
                                height: context.h(50),
                                width: context.h(50),
                                fit: BoxFit.cover,
                                key: ValueKey(homeViewModel.currentUser!.profileImageUrl), // Force reload when URL changes
                                cacheWidth: context.h(50).toInt(),
                                cacheHeight: context.h(50).toInt(),
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholder(context);
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: context.h(50),
                                        width: context.h(50),
                                        decoration: BoxDecoration(
                                          color: context.subtitleColor
                                              .withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: AppLoadingIndicator.small(),
                                        ),
                                      );
                                    },
                              )
                            : Container(
                                height: context.h(50),
                                width: context.h(50),
                                decoration: BoxDecoration(
                                  color: context.subtitleColor.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: context.h(30),
                                  color: context.textColor.withOpacity(0.7),
                                ),
                              ),
                      ),
                      title: Text(
                        'Hello, ${_getDisplayName(homeViewModel.currentUser)} 👋',
                        style: context.appTextStyles?.homeGreetingTitle,
                      ),
                      subtitle: Text(
                        'Ready to build your perfect wallpaper?',
                        style: context.appTextStyles?.homeGreetingSubtitle,
                      ),
                    ),
                  ),
                ),

                // Generate Wallpaper Card
                SliverToBoxAdapter(child: SizedBox(height: context.h(24))),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        dashPattern: [10, 10],
                        strokeWidth: context.w(1),
                        radius: Radius.circular(context.radius(12)),
                        color: context.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.all(context.w(20)),
                        children: [
                          Container(
                            padding: EdgeInsets.all(context.w(14)),
                            decoration: BoxDecoration(
                              color: context.colorScheme.onSurface,
                              shape: BoxShape.circle,
                              gradient: AppColors.gradient,
                            ),
                            child: SvgPicture.asset(
                              AppAssets.startIcon,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                          SizedBox(height: context.h(12)),
                          Text(
                            'Create Your Perfect Wallpaper',
                            style: context.appTextStyles?.homeCardTitle,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: context.h(12)),
                          Text(
                            'Use AI to generate stunning wallpapers tailored to your style. From abstract art to breathtaking landscapes.',
                            style: context.appTextStyles?.homeCardDescription,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: context.h(12)),
                          CustomButton(
                            onPressed: () => homeViewModel
                                .navigateToGenarateWallpaperScreen(context),
                            height: context.h(47),
                            width: context.w(160),
                            gradient: AppColors.gradient,
                            text: homeViewModel.isLoading
                                ? 'Creating...'
                                : 'Generate Now',
                            isLoading: homeViewModel.isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Dynamic Categories from API
                if (homeViewModel.isLoadingGroupedWallpapers) ...[
                  // Show loading indicator while fetching grouped wallpapers
                  SliverToBoxAdapter(child: SizedBox(height: context.h(40))),
                  SliverToBoxAdapter(
                    child: Center(
                      child: AppLoadingIndicator.large(),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: context.h(20))),
                ] else if (homeViewModel.groupedWallpapers.isEmpty) ...[
                  // Show message when no wallpapers are available
                  SliverToBoxAdapter(child: SizedBox(height: context.h(20))),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(context.w(20)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,  
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: context.h(60),
                            color: context.subtitleColor.withOpacity(0.5),
                          ),
                          SizedBox(height: context.h(12)),
                            Text(
                              'No wallpapers yet',
                              style: context.appTextStyles?.homeCardTitle,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: context.h(8)),
                            Text(
                              'Create your first wallpaper to see it here!',
                              style: context.appTextStyles?.homeCardDescription,
                              textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  ...homeViewModel.groupedWallpapers.entries.map((entry) {
                    final categoryName = entry.key;
                    final wallpapers = entry.value;
                    
                    // Only show categories that have wallpapers
                    if (wallpapers.isEmpty) return <Widget>[];
                    
                    return [
                      SliverToBoxAdapter(child: SizedBox(height: context.h(20))),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                          child: HomeAlign(
                            text: categoryName,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CategoryDetailsScreen(
                                    categoryName: categoryName,
                                    wallpapers: wallpapers,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: context.h(12))),
                      SliverToBoxAdapter(
                        child: CustomListView(wallpapers: wallpapers),
                      ),
                    ];
                  }).expand((widgets) => widgets).toList(),
                ],

                // Bottom Padding
                SliverToBoxAdapter(child: SizedBox(height: context.h(100))),
              ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getDisplayName(User? user) {
    if (user == null) return 'User';

    // Try to get display name in order: username -> fullName -> firstName -> email
    if (user.username != null && user.username!.isNotEmpty) {
      return user.username!;
    }

    final fullName = user.fullName;
    if (fullName.isNotEmpty && fullName != 'User') {
      return fullName;
    }

    if (user.firstName != null && user.firstName!.isNotEmpty) {
      return user.firstName!;
    }

    if (user.email != null && user.email!.isNotEmpty) {
      // Extract name from email (part before @)
      final emailParts = user.email!.split('@');
      if (emailParts.isNotEmpty) {
        return emailParts[0];
      }
    }

    return 'User';
  }
}

// Delegate for pinned user profile header
class _UserProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _UserProfileHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height; // Minimum height when collapsed

  @override
  double get maxExtent => height; // Maximum height when expanded

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      height: height,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(_UserProfileHeaderDelegate oldDelegate) {
    return child != oldDelegate.child || height != oldDelegate.height;
  }
}
