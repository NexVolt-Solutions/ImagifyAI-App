import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';

class ProfileScreenViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> profileData = [
    {
      'leading': AppAssets.profileIcon,
      'title': 'My profile',
      'subtitle': 'Edit Profile',
      'trailingType': 'arrow',
      'switchValue': false,
    },
    {
      'leading': AppAssets.themeIcon,
      'title': 'Theme',
      'subtitle': 'Light Mode',
      'trailingType': 'switch',
      'switchValue': true,
    },
    {
      'leading': AppAssets.bellIcon,
      'title': 'Notification',
      'subtitle': 'Push Notifcation enabled',
      'trailingType': 'switch',
      'switchValue': true,
    },
    {
      'leading': AppAssets.shieldIcon,
      'title': 'Privacy Policy',
      'subtitle': 'Read how we collect and protect your data',
      'trailingType': 'arrow',
      'switchValue': false,
    },
    {
      'leading': AppAssets.termIcon,
      'title': 'Terms of Service',
      'subtitle': 'Read our terms of services',
      'trailingType': 'arrow',
      'switchValue': false,
    },
    {
      'leading': AppAssets.contactIcon,
      'title': 'Contact Us',
      'subtitle': 'Contact us from your phone',
      'trailingType': 'arrow',
      'switchValue': false,
    },
  ];

  void onTapFun(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushNamed(context, RoutesName.EditScreen);
    } else if (index == 3) {
      Navigator.pushNamed(context, RoutesName.PrivicyScreen);
    } else if (index == 4) {
      Navigator.pushNamed(context, RoutesName.TermScreen);
    } else if (index == 5) {
      Navigator.pushNamed(context, RoutesName.ContactScreen);
    }
  }
}
