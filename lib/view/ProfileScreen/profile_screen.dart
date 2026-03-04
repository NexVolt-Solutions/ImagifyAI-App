import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/custom_button.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/view/ProfileScreen/widget/profile_header_section.dart';
import 'package:imagifyai/view/ProfileScreen/widget/profile_menu_list.dart';
import 'package:imagifyai/viewModel/profile_screen_view_model.dart';
import 'package:imagifyai/viewModel/sign_in_view_model.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hasLoaded = false;

  Future<void> _showSignOutConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Sign out',
          style: TextStyle(
            color: context.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: context.textColor),
        ),
        backgroundColor: context.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.radius(12)),
          side: BorderSide(color: context.primaryColor, width: 2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.subtitleColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Sign out',
              style: TextStyle(
                color: context.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<SignInViewModel>().logout(context);
    }
  }

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
                ProfileHeaderSection(user: user),
                ProfileMenuList(viewModel: profileScreenViewModel),
                SizedBox(height: context.h(20)),
                CustomButton(
                  onPressed: () => _showSignOutConfirmation(context),
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
