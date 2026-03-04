import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';
import 'package:imagifyai/Core/CustomWidget/custom_list_view.dart';
import 'package:imagifyai/Core/CustomWidget/home_align.dart';
import 'package:imagifyai/Core/services/home_permission_service.dart';
import 'package:imagifyai/Core/services/in_app_review_service.dart';
import 'package:imagifyai/Core/services/local_notification_service.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/view/CategoryDetails/category_details_screen.dart';
import 'package:imagifyai/view/Home/widgets/generate_wallpaper_card.dart';
import 'package:imagifyai/view/Home/widgets/home_empty_wallpapers.dart';
import 'package:imagifyai/view/Home/widgets/user_profile_header.dart';
import 'package:imagifyai/viewModel/home_view_model.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoaded) return;
    _hasLoaded = true;

    final homeViewModel = context.read<HomeViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        // Ask for storage/photos permission once (so save-to-gallery works)
        await HomePermissionService.requestIfFirstTime();
        if (!mounted) return;
        // Record first open (for 5-day review trigger)
        await InAppReviewService.recordFirstOpenIfNeeded();
        // Gentle review reminder in 3 days if not yet asked
        await LocalNotificationService.scheduleReviewReminderIfEligible(
          daysFromNow: 3,
          hasRequestedReview: InAppReviewService.hasRequestedReview,
        );
        // Load all data in parallel for faster loading
        if (!mounted) return;
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
                  UserProfileHeader(
                    currentUser: homeViewModel.currentUser,
                    displayName: UserProfileHeader.getDisplayName(homeViewModel.currentUser),
                    isProfileLoading: homeViewModel.isLoadingUser,
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: context.h(24))),
                  SliverToBoxAdapter(
                    child: GenerateWallpaperCard(
                      onGenerateTap: () => homeViewModel
                          .navigateToGenerateWallpaperScreen(context),
                      isLoading: homeViewModel.isLoading,
                    ),
                  ),
                  if (homeViewModel.isLoadingGroupedWallpapers) ...[
                    SliverToBoxAdapter(child: SizedBox(height: context.h(40))),
                    SliverToBoxAdapter(
                      child: Center(child: AppLoadingIndicator.large()),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: context.h(20))),
                  ] else if (homeViewModel.groupedWallpapers.isEmpty) ...[
                    SliverToBoxAdapter(child: SizedBox(height: context.h(20))),
                    SliverToBoxAdapter(child: HomeEmptyWallpapers()),
                  ] else ...[
                    ...homeViewModel.groupedWallpapers.entries
                        .map((entry) {
                          final categoryName = entry.key;
                          final wallpapers = entry.value;

                          // Only show categories that have wallpapers
                          if (wallpapers.isEmpty) return <Widget>[];

                          return [
                            SliverToBoxAdapter(
                              child: SizedBox(height: context.h(20)),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.h(20),
                                ),
                                child: HomeAlign(
                                  text: categoryName,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CategoryDetailsScreen(
                                              categoryName: categoryName,
                                              wallpapers: wallpapers,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(height: context.h(12)),
                            ),
                            SliverToBoxAdapter(
                              child: CustomListView(wallpapers: wallpapers),
                            ),
                          ];
                        })
                        .expand((widgets) => widgets),
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
}
