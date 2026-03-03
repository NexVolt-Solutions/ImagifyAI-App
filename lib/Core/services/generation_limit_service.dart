import 'package:imagifyai/Core/services/rewarded_ad_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks daily generation limit and ad-earned credits.
/// When user is at limit, they can watch a rewarded ad for +1 generation.
class GenerationLimitService {
  static const String _keyGenerationsUsedToday = 'generations_used_today';
  static const String _keyLastLimitDate = 'generation_limit_date';

  /// Free generations per day before requiring an ad or limit.
  static const int dailyLimit = 5;

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Reset daily count if we're on a new day.
  static Future<void> _ensureDateReset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final last = prefs.getString(_keyLastLimitDate);
      final today = _todayString();
      if (last != today) {
        await prefs.setString(_keyLastLimitDate, today);
        await prefs.setInt(_keyGenerationsUsedToday, 0);
      }
    } catch (_) {}
  }

  /// Whether the user can generate (under daily limit or has ad credits).
  static Future<bool> canGenerate() async {
    await _ensureDateReset();
    final used = await _getGenerationsUsedToday();
    if (used < dailyLimit) return true;
    final adCredits = await RewardedAdService.getFreeGenerationsFromAds();
    return adCredits > 0;
  }

  /// Generations used today (after date reset).
  static Future<int> getGenerationsUsedToday() async {
    await _ensureDateReset();
    return _getGenerationsUsedToday();
  }

  static Future<int> _getGenerationsUsedToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyGenerationsUsedToday) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Call when a generation (create or recreate) succeeds.
  /// Uses daily allowance first, then consumes one ad credit if at limit.
  static Future<void> recordGeneration() async {
    await _ensureDateReset();
    try {
      final prefs = await SharedPreferences.getInstance();
      int used = prefs.getInt(_keyGenerationsUsedToday) ?? 0;
      if (used < dailyLimit) {
        await prefs.setInt(_keyGenerationsUsedToday, used + 1);
      } else {
        await RewardedAdService.consumeOneFreeGeneration();
      }
    } catch (_) {}
  }
}
