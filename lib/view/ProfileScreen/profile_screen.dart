import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/custom_button.dart';
import 'package:imagifyai/Core/CustomWidget/full_screen_image_viewer.dart';
import 'package:imagifyai/Core/CustomWidget/profile_image.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/profile_screen_view_model.dart';
import 'package:imagifyai/viewModel/sign_in_view_model.dart';
import 'package:imagifyai/viewModel/theme_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoaded) return;
    _hasLoaded = true;

    final signInViewModel = context.read<SignInViewModel>();
    final profileViewModel = context.read<ProfileScreenViewModel>();

    // Always try to load user data (will check if reload is needed internally)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        profileViewModel.loadCurrentUser(
          accessToken: signInViewModel.accessToken,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileScreenViewModel>(
      builder: (context, profileScreenViewModel, _) {
        final user = profileScreenViewModel.currentUser;

        return Scaffold(
          backgroundColor: context.backgroundColor,

          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: context.h(20)),
              children: [
                SizedBox(height: context.h(20)),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      final imageUrl = user?.profileImageUrl ?? '';
                      if (imageUrl.isNotEmpty) {
                        final heroTag =
                            'profile_image_${user?.id ?? 'default'}';
                        FullScreenImageViewer.show(
                          context,
                          imageUrl,
                          heroTag: heroTag,
                        );
                      }
                    },
                    child: Hero(
                      tag: 'profile_image_${user?.id ?? 'default'}',
                      child: ProfileImage(
                        imagePath: user?.profileImageUrl ?? '',
                        height: context.h(100),
                        width: context.h(100),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.h(12)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      user?.fullName ?? "User",
                      style: context.appTextStyles?.profileName,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.h(4)),
                    Text(
                      user?.email ?? "",
                      style: context.appTextStyles?.profileEmail,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                ListView.builder(
                  itemCount: profileScreenViewModel.profileData.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = profileScreenViewModel.profileData[index];
                    final isThemeItem = item['title'] == 'Theme';

                    // Get theme provider for theme toggle
                    final themeProvider = isThemeItem
                        ? Provider.of<ThemeProvider>(context)
                        : null;
                    final isDarkMode = themeProvider?.isDarkMode ?? false;

                    return ListTile(
                      onTap: () =>
                          profileScreenViewModel.onTapFun(context, index),
                      contentPadding: EdgeInsets.zero,
                      leading: item['leading'] != null
                          ? Image.asset(
                              item['leading'],
                              height: context.h(26),
                              width: context.w(26),
                              fit: BoxFit.contain,
                            )
                          : const SizedBox.shrink(),
                      title: Text(
                        item['title'] ?? '',
                        style: context.appTextStyles?.profileListItemTitle,
                      ),
                      subtitle: Text(
                        isThemeItem
                            ? (isDarkMode ? 'Dark Mode' : 'Light Mode')
                            : (item['subtitle'] ?? ''),
                        style: context.appTextStyles?.profileListItemSubtitle,
                      ),
                      trailing: item['trailingType'] == 'switch'
                          ? Switch(
                              inactiveThumbColor: context.subtitleColor,
                              activeTrackColor: context.textColor,
                              activeThumbColor: context.primaryColor,
                              value: isThemeItem
                                  ? isDarkMode
                                  : (item['switchValue'] ?? false),
                              onChanged: (val) {
                                if (isThemeItem) {
                                  // Toggle theme using ThemeProvider
                                  themeProvider?.toggleTheme();
                                } else {
                                  // Handle other switches
                                  setState(() {
                                    item['switchValue'] = val;
                                  });
                                }
                              },
                              activeColor: context.textColor,
                            )
                          : Icon(
                              Icons.arrow_forward_ios,
                              color: context.textColor,
                              size: 16,
                            ),
                    );
                  },
                ),
                SizedBox(height: context.h(20)),
                CustomButton(
                  onPressed: () =>
                      context.read<SignInViewModel>().logout(context),

                  width: context.w(350),
                  gradient: AppColors.gradient,
                  text: 'Sign out',
                ),
                SizedBox(height: context.h(100)),
              ],
            ),
          ),
        );
      },
    );
  }
}
