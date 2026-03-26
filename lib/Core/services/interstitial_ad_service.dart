import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:imagifyai/Core/Constants/env_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AdMob Interstitial ad shown after natural breaks (e.g. after download).
/// Ad unit ID from .env (ADMOB_INTERSTITIAL_AD_UNIT_ID). In debug, uses Google test ID so ads always load.
class InterstitialAdService {
  static const String _lastShownMsKey = 'ads_interstitial_last_shown_ms';
  static String get interstitialAdUnitId => kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712' // Google test interstitial
      : EnvConstants.admobInterstitialAdUnitId;

  static InterstitialAd? _interstitialAd;
  static bool _isLoading = false;
  static bool _retryDone = false;

  /// Load an interstitial so it's ready to show. Retries once on failure (code 0 or 3).
  static Future<void> loadInterstitialAd() async {
    if (_interstitialAd != null || _isLoading) return;
    if (interstitialAdUnitId.isEmpty || interstitialAdUnitId.contains('xxxx')) {
      return;
    }
    _isLoading = true;
    if (kDebugMode) {
      // ignore: avoid_print
      print(
        'InterstitialAdService: loading with adUnitId=${interstitialAdUnitId.substring(0, 30)}...',
      );
    }
    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isLoading = false;
            _retryDone = false;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _interstitialAd = null;
                loadInterstitialAd(); // Preload next
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _interstitialAd = null;
                _isLoading = false;
              },
            );
          },
          onAdFailedToLoad: (error) {
            _isLoading = false;
            if (!_retryDone &&
                (error.code == 0 || error.code == 3) &&
                kDebugMode) {
              _retryDone = true;
              Future<void>.delayed(const Duration(seconds: 3), () {
                loadInterstitialAd();
              });
            }
          },
        ),
      );
    } catch (e) {
      _isLoading = false;
    }
  }

  /// Show the interstitial. Call after a natural break (e.g. after user downloads an image).
  /// Returns true if ad was shown, false if not ready or ID not set.
  static Future<bool> showInterstitialAd() async {
    if (interstitialAdUnitId.isEmpty || interstitialAdUnitId.contains('xxxx')) {
      return false;
    }
    if (_interstitialAd == null) {
      await loadInterstitialAd();
      if (_interstitialAd == null) return false;
    }
    final ad = _interstitialAd!;
    _interstitialAd = null;
    await ad.show();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _lastShownMsKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {}
    return true;
  }

  static Future<bool> shouldShowAfterGenerationBreak({
    required int generationCount,
    int everyN = 5,
    Duration cooldown = const Duration(seconds: 30),
  }) async {
    if (generationCount <= 0 || everyN <= 0) return false;
    if (generationCount % everyN != 0) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastMs = prefs.getInt(_lastShownMsKey) ?? 0;
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      return nowMs - lastMs >= cooldown.inMilliseconds;
    } catch (_) {
      return true;
    }
  }
}
