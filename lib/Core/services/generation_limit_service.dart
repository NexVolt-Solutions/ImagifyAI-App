import 'package:imagifyai/Core/services/server_clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks **interstitial pacing** and total generations in a **rolling 24-hour window**
/// (from the stored window start). Window time uses [ServerClock] (HTTP `Date`), not raw
/// device clock.
///
/// **Wallpaper quota** (5 → rewarded → 3 → …) is enforced by the server; use
/// [GET /wallpapers/usage] via [ImageGenerateViewModel.loadDailyUsage].
class GenerationLimitService {
  static const String _keyRollingWindowStartMs =
      'generation_rolling_window_start_ms';
  static const String _keyTotalGenerationsAllTime = 'generations_total_all_time';
  /// Successful generations in the current window for interstitial pacing.
  static const String _keyAdPacingGensToday = 'ad_pacing_gens_today';

  /// Length of the rolling window for ad pacing.
  static const Duration rollingWindow = Duration(hours: 24);

  /// If server-aligned [nowMs] − window start ≥ [rollingWindow], resets pacing counter.
  static Future<void> _ensureRollingWindowReset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nowMs = await ServerClock.nowMs();
      final startMs = prefs.getInt(_keyRollingWindowStartMs);
      final elapsedMs = startMs != null && nowMs >= startMs
          ? nowMs - startMs
          : 0;
      final expired =
          startMs == null ||
          elapsedMs >= rollingWindow.inMilliseconds;
      if (expired) {
        await prefs.setInt(_keyRollingWindowStartMs, nowMs);
        await prefs.setInt(_keyAdPacingGensToday, 0);
      }
    } catch (_) {}
  }

  /// Count for interstitial pacing in the current rolling window (every successful create/recreate).
  static Future<int> getGenerationsTodayForAdPacing() async {
    await _ensureRollingWindowReset();
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyAdPacingGensToday) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Total successful generations across all time (not reset by rolling window).
  static Future<int> getTotalGenerationsAllTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyTotalGenerationsAllTime) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Call when a generation (create or recreate) succeeds (interstitial pacing + totals).
  static Future<void> recordGeneration() async {
    await _ensureRollingWindowReset();
    try {
      final prefs = await SharedPreferences.getInstance();
      final pacing = prefs.getInt(_keyAdPacingGensToday) ?? 0;
      await prefs.setInt(_keyAdPacingGensToday, pacing + 1);
      final total = prefs.getInt(_keyTotalGenerationsAllTime) ?? 0;
      await prefs.setInt(_keyTotalGenerationsAllTime, total + 1);
    } catch (_) {}
  }
}
