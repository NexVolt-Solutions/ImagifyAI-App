import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:genwalls/Core/CustomWidget/custom_button.dart';
import 'package:genwalls/Core/CustomWidget/custom_list_view.dart';
import 'package:genwalls/Core/CustomWidget/home_align.dart';
import 'package:genwalls/Core/theme/theme_extensions.dart';
import 'package:genwalls/models/user/user.dart';
import 'package:genwalls/viewModel/home_view_model.dart';
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
    
    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('=== HOME SCREEN: didChangeDependencies CALLED ===');
      print('═══════════════════════════════════════════════════════════');
    }
    
  
    final homeViewModel = context.read<HomeViewModel>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        // Small delay to ensure context is fully ready
        await Future.delayed(const Duration(milliseconds: 200));
        
        if (mounted) {
          if (kDebugMode) {
            print('✅ Calling loadCurrentUser...');
          }
          homeViewModel.loadCurrentUser(context);
        }
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
        child: CustomScrollView(
          slivers: [
            // User Profile Section - Pinned
            SliverPersistentHeader(
              pinned: true,
               delegate: _UserProfileHeaderDelegate(
                height: 85.0,
                child: SizedBox(
                  height: 85.0,
                  child: ListTile(    
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: context.w(16),
                      vertical: context.h(8),
                    ),
                    leading: ClipOval(
                    child: homeViewModel.currentUser?.profileImageUrl != null &&
                            homeViewModel.currentUser!.profileImageUrl!.isNotEmpty
                        ? Image.network(
                            homeViewModel.currentUser!.profileImageUrl!,
                            height: context.h(50),
                            width: context.h(50),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
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
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: context.h(50),
                                width: context.h(50),
                                decoration: BoxDecoration(
                                  color: context.subtitleColor.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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
            ),
            
          
          
            
            // Generate Wallpaper Card
            SliverToBoxAdapter(
              child: SizedBox(height: context.h(19)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                child: DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    dashPattern: [10, 5],
                    strokeWidth: context.w(2),
                    radius: Radius.circular(context.radius(12)),
                    color: context.colorScheme.onSurface,
                  ),
                  child: Container(
                    height: context.h(318),
                    width: context.w(double.infinity),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.radius(12)),
                    ),
                    child: ListView(
                      padding: EdgeInsets.all (   context.w(20)),
                       children: [
                         Image.asset(
                          AppAssets.dotConIcon,
                          height: context.h(60),
                          width: context.w(60),
                          fit: BoxFit.contain,
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
                          onPressed: () => homeViewModel.navigateToGenarateWallpaperScreen(context),
                          height: context.h(47),
                          width: context.w(160),
                          gradient: AppColors.gradient,
                          text: homeViewModel.isLoading
                              ? 'Creating...'
                              : 'Generate Now',
                        ),
                       ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Trending Section
            SliverToBoxAdapter(
              child: SizedBox(height: context.h(20)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                child: HomeAlign(text: 'Trending'),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: context.h(12)),
            ),
            SliverToBoxAdapter(
              child: CustomListView(image: null),
            ),
            
            // Nature Section
            SliverToBoxAdapter(
              child: SizedBox(height: context.h(20)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                child: HomeAlign(text: 'Nature'),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: context.h(12)),
            ),
            SliverToBoxAdapter(
              child: CustomListView(image: null),
            ),
            
            // 3D Render Section
            SliverToBoxAdapter(
              child: SizedBox(height: context.h(20)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.h(20)),
                child: HomeAlign(text: '3D Render'),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: context.h(12)),
            ),
            SliverToBoxAdapter(
              child: CustomListView(image: null),
            ),
            
            // Bottom Padding
            SliverToBoxAdapter(
              child: SizedBox(height: context.h(100)),
            ),
          ],
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
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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
