import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Asks for storage/photos permission once when the user first lands on Home
/// (e.g. after signup/signin). Used so saving wallpapers to gallery works.
class HomePermissionService {
  HomePermissionService._();

  static const String _keyRequested = 'home_photos_storage_permission_requested';

  /// Call once when Home is first shown (e.g. after login).
  /// Requests storage/photos permission so "Save to device" can add images to the gallery.
  /// Only prompts once per install; later visits do not ask again.
  static Future<void> requestIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_keyRequested) == true) return;

    await prefs.setBool(_keyRequested, true);

    if (Platform.isIOS) {
      await Permission.photos.request();
      return;
    }

    if (Platform.isAndroid) {
      // Android 12 and below: storage; Android 13+: photos (READ_MEDIA_IMAGES)
      await Permission.storage.request();
      await Permission.photos.request();
    }
  }
}
