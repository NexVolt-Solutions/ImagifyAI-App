import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/profile_screen_view_model.dart';
import 'package:imagifyai/viewModel/theme_provider.dart';
import 'package:provider/provider.dart';

class ProfileMenuList extends StatelessWidget {
  final ProfileScreenViewModel viewModel;

  const ProfileMenuList({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: viewModel.profileData.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = viewModel.profileData[index];
        final isThemeItem = item['title'] == 'Theme';
        final themeProvider = isThemeItem
            ? Provider.of<ThemeProvider>(context)
            : null;
        final isDarkMode = themeProvider?.isDarkMode ?? false;

        return ListTile(
          onTap: item['trailingType'] == 'switch'
              ? null
              : () => viewModel.onTapFun(context, index),
          contentPadding: EdgeInsets.zero,
          leading: item['leading'] != null
              ? Image.asset(
                  item['leading'],
                  height: context.h(24),
                  width: context.w(24),
                  color: context.primaryColor,
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
                : (item['title'] == 'Notifications'
                      ? (viewModel.notificationsEnabled ? 'On' : 'Off')
                      : (item['subtitle'] ?? '')),
            style: context.appTextStyles?.profileListItemSubtitle,
          ),
          trailing: item['trailingType'] == 'switch'
              ? Switch(
                  inactiveThumbColor: context.subtitleColor,
                  inactiveTrackColor: Colors.transparent,
                  activeTrackColor: context.textColor,
                  activeThumbColor: context.primaryColor,
                  trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.transparent; // no border when active
                    }
                    return context.subtitleColor; // border when inactive
                  }),
                  value: isThemeItem
                      ? isDarkMode
                      : viewModel.notificationsEnabled,
                  onChanged: (val) {
                    if (isThemeItem) {
                      themeProvider?.toggleTheme();
                    } else {
                      viewModel.setNotificationsEnabled(val);
                    }
                  },
                )
              //  Switch(
              //     inactiveThumbColor: context.subtitleColor,
              //     activeTrackColor: context.textColor,
              //     activeThumbColor: context.primaryColor,
              //     value: isThemeItem
              //         ? isDarkMode
              //         : viewModel.notificationsEnabled,
              //     onChanged: (val) {
              //       if (isThemeItem) {
              //         themeProvider?.toggleTheme();
              //       } else {
              //         viewModel.setNotificationsEnabled(val);
              //       }
              //     },
              //   )
              : Icon(
                  Icons.arrow_forward_ios,
                  color: context.textColor,
                  size: 16,
                ),
        );
      },
    );
  }
}
