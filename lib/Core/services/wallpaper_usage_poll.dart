import 'package:imagifyai/models/user/usage_response.dart';

class WallpaperUsagePoll {
  WallpaperUsagePoll._();

  static Future<UsageResponse?> waitForPositiveRemaining({
    required Future<UsageResponse> Function() fetchUsage,
    Duration interval = const Duration(milliseconds: 700),
    int maxAttempts = 50,
  }) async {
    for (var i = 0; i < maxAttempts; i++) {
      if (i > 0) {
        await Future<void>.delayed(interval);
      }
      try {
        final u = await fetchUsage();
        if (u.remaining > 0) {
          return u;
        }
      } catch (_) {}
    }
    return null;
  }
}
