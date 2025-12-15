import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_assets.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/models/user/user.dart';
import 'package:genwalls/repositories/auth_repository.dart';

class ProfileScreenViewModel extends ChangeNotifier {
  ProfileScreenViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  User? currentUser;
  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> profileData = [
    {
      'leading': AppAssets.profileIcon,
      'title': 'My profile',
      'subtitle': 'Edit Profile',
      'trailingType': 'arrow',
      'switchValue': false,
    },
    {
      'leading': AppAssets.profileIcon,
      'title': 'Library',
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

  Future<void> loadCurrentUser({String? accessToken, bool forceReload = false}) async {
    if (isLoading) return;
    
    // Skip if user data already loaded and not forcing reload
    if (!forceReload && currentUser != null) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await _authRepository.getCurrentUser(accessToken: accessToken);
      errorMessage = null; // Clear any previous errors on success
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Failed to load user data';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onTapFun(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushNamed(context, RoutesName.EditScreen);
    } else if (index == 1) {
      Navigator.pushNamed(context, RoutesName.LibraryScreen);
    } else if (index == 4) {
      Navigator.pushNamed(context, RoutesName.PrivicyScreen);
    } else if (index == 5) {
      Navigator.pushNamed(context, RoutesName.TermScreen);
    } else if (index == 6) {
      Navigator.pushNamed(context, RoutesName.ContactScreen);
    }
  }
}
