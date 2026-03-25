import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/services/content_report_service.dart';
import 'package:imagifyai/Core/services/local_notification_service.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/Core/services/token_storage_service.dart';
import 'package:imagifyai/Core/utils/Routes/routes_name.dart';
import 'package:imagifyai/models/user/user.dart';
import 'package:imagifyai/domain/repositories/auth_repository_interface.dart';
import 'package:imagifyai/domain/repositories/auth_repository.dart';

class ProfileScreenViewModel extends ChangeNotifier {
  ProfileScreenViewModel({IAuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final IAuthRepository _authRepository;

  User? currentUser;
  bool isLoading = false;
  String? errorMessage;
  bool notificationsEnabled = false;

  /// Increment after profile photo changes so widgets use a new network cache key.
  int _profileImageCacheNonce = 0;
  int get profileImageCacheNonce => _profileImageCacheNonce;

  void bumpProfileImageCacheNonce() {
    _profileImageCacheNonce++;
    notifyListeners();
  }

  Future<void> loadNotificationPreference() async {
    final enabled = await LocalNotificationService.areRetentionRemindersEnabled();
    if (notificationsEnabled != enabled) {
      notificationsEnabled = enabled;
      notifyListeners();
    }
  }

  Future<void> setNotificationsEnabled(bool value) async {
    if (notificationsEnabled == value) return;
    notificationsEnabled = value;
    notifyListeners();
    await LocalNotificationService.setRetentionRemindersEnabled(value);
    if (value) {
      await LocalNotificationService.rescheduleDailyReturnNudgeIfEligible(
        ignoreDebounce: true,
      );
    }
  }

  List<Map<String, dynamic>> profileData = [
    {
      'leading': AppAssets.profileIcon,
      'title': 'My Profile',
      'subtitle': 'View and edit your profile information',
      'trailingType': 'arrow',
      'switchValue': false,
    },
    {
      'leading': AppAssets.profileIcon,
      'title': 'Library',
      'subtitle': 'Browse your generated wallpapers',
      'trailingType': 'arrow',
      'switchValue': false,
    },
    {
      'leading': AppAssets.shieldIcon,
      'title': 'Account',
      'subtitle': 'Change password and account security',
      'trailingType': 'arrow',
      'switchValue': false,
    },
    {
      'leading': AppAssets.themeIcon,
      'title': 'Theme',
      'subtitle': 'Dark Mode', // Will be updated dynamically based on theme
      'trailingType': 'switch',
      'switchValue': true, // Will be synced with ThemeProvider
    },
    {
      'leading': AppAssets.bellIcon,
      'title': 'Notifications',
      'subtitle': 'Occasional reminders to create wallpaper',
      'trailingType': 'switch',
      'switchValue': false,
    },
    {
      'leading': AppAssets.shieldIcon,
      'title': 'Privacy Policy',
      'subtitle': 'Learn how we protect your privacy',
      'trailingType': 'arrow',
      'switchValue': false,
    },
    {
      'leading': AppAssets.shieldIcon,
      'title': 'Report offensive content',
      'subtitle': 'Flag inappropriate AI-generated content',
      'trailingType': 'arrow',
      'switchValue': false,
    },
    {
      'leading': AppAssets.termIcon,
      'title': 'Terms of Service',
      'subtitle': 'Read our terms and conditions',
      'trailingType': 'arrow',
      'switchValue': false,
    },
    {
      'leading': AppAssets.contactIcon,
      'title': 'Contact Us',
      'subtitle': 'Get help or share feedback',
      'trailingType': 'arrow',
      'switchValue': false,
    },
  ];

  Future<void> loadCurrentUser({
    String? accessToken,
    bool forceReload = false,
  }) async {
    // Allow force reload while a previous load is in flight (e.g. after saving edit profile)
    if (isLoading && !forceReload) return;

    if (accessToken == null || accessToken.isEmpty) {
      // User not logged in, clear cached user
      if (currentUser != null) {
        currentUser = null;
        notifyListeners();
      }
      return;
    }

    // Get userId from storage to check if user changed
    final userId = await TokenStorageService.getUserId();
    if (userId == null || userId.isEmpty) {
      // No user ID means not logged in, clear cached user
      if (currentUser != null) {
        currentUser = null;
        notifyListeners();
      }
      return;
    }

    // Check if the stored userId matches the cached user.
    // On forceReload, keep showing the previous user until the new payload arrives
    // (clearing here caused an empty avatar / placeholder flash).
    if (!forceReload && currentUser != null) {
      if (currentUser!.id == userId) {
        // User already loaded and matches stored user ID, skip reload
        return;
      } else {
        // Clear cached user since it's a different user
        currentUser = null;
        notifyListeners();
      }
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await _authRepository.getCurrentUser(
        accessToken: accessToken,
        userId: userId,
        forceRefresh: forceReload,
      );
      errorMessage = null; // Clear any previous errors on success
    } on ApiException catch (e) {
      errorMessage = e.message;
      // Set currentUser to null so UI doesn't try to display invalid data
      currentUser = null;
    } catch (_) {
      errorMessage = 'Failed to load user data';
      currentUser = null;
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
    } else if (index == 2) {
      Navigator.pushNamed(context, RoutesName.ChangePasswordScreen);
    } else if (index == 5) {
      Navigator.pushNamed(context, RoutesName.PrivicyScreen);
    } else if (index == 6) {
      ContentReportService.showReportInfoDialog(context);
    } else if (index == 7) {
      Navigator.pushNamed(context, RoutesName.TermScreen);
    } else if (index == 8) {
      Navigator.pushNamed(context, RoutesName.ContactScreen);
    }
  }

}
