import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:imagifyai/Core/Constants/env_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AdMob Rewarded ad for "Watch ad for 1 free generation".
/// Ad unit ID from .env (ADMOB_REWARDED_AD_UNIT_ID). In debug, uses Google test ID so ads always load.
class RewardedAdService {
  static const String _keyFreeGenerationsFromAds = 'free_generations_from_ads';

  static String get rewardedAdUnitId =>
      kDebugMode
          ? 'ca-app-pub-3940256099942544/5224354917' // Google test rewarded
          : EnvConstants.admobRewardedAdUnitId;

  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;
  static bool _retryDone = false;

  /// Load a rewarded ad so it's ready to show. Retries once on failure (code 0 or 3).
  static Future<void> loadRewardedAd() async {
    if (_rewardedAd != null || _isLoading) return;
    _isLoading = true;
    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isLoading = false;
            _retryDone = false;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _rewardedAd = null;
                loadRewardedAd(); // Preload next
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _rewardedAd = null;
                _isLoading = false;
              },
            );
          },
          onAdFailedToLoad: (error) {
            _isLoading = false;
            if (!_retryDone && (error.code == 0 || error.code == 3)) {
              _retryDone = true;
              Future<void>.delayed(const Duration(seconds: 3), () {
                loadRewardedAd();
              });
            }
          },
        ),
      );
    } catch (e) {
      _isLoading = false;
    }
  }

  /// Show the rewarded ad. [onReward] is called when user earns the reward.
  /// Returns true if ad was shown, false if not ready or failed.
  static Future<bool> showRewardedAd({
    required void Function() onReward,
  }) async {
    if (_rewardedAd == null) {
      await loadRewardedAd();
      if (_rewardedAd == null) return false;
    }
    final ad = _rewardedAd!;
    _rewardedAd = null;
    ad.show(
      onUserEarnedReward: (_, reward) {
        _incrementFreeGenerationsFromAds();
        onReward();
      },
    );
    return true;
  }

  static Future<void> _incrementFreeGenerationsFromAds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_keyFreeGenerationsFromAds) ?? 0;
      await prefs.setInt(_keyFreeGenerationsFromAds, current + 1);
    } catch (_) {}
  }

  /// Number of free generations earned by watching ads (for future limit logic).
  static Future<int> getFreeGenerationsFromAds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyFreeGenerationsFromAds) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Consume one free generation (call when user actually generates).
  static Future<void> consumeOneFreeGeneration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_keyFreeGenerationsFromAds) ?? 0;
      if (current > 0) {
        await prefs.setInt(_keyFreeGenerationsFromAds, current - 1);
      }
    } catch (_) {}
  }
}
