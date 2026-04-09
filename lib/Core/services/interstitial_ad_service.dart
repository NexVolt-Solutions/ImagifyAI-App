import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:imagifyai/Core/Constants/env_constants.dart';
import 'package:imagifyai/Core/services/generation_limit_service.dart';
import 'package:imagifyai/Core/services/server_clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InterstitialAdService {
  static const String _lastShownMsKey = 'ads_interstitial_last_shown_ms';
  static const String _firstSessionCompletedKey =
      'ads_interstitial_first_session_completed';
  static bool get _enabled => EnvConstants.adsEnableInterstitial;
  static String get interstitialAdUnitId => kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712'
      : EnvConstants.admobInterstitialAdUnitId;

  static InterstitialAd? _interstitialAd;
  static bool _isLoading = false;
  static bool _retryDone = false;
  static Completer<void>? _loadCompleter;

  static Future<void> _markInterstitialShownNow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastShownMsKey, await ServerClock.nowMs());
    } catch (_) {}
  }

  /// Call when app leaves foreground so first-session gating can be lifted.
  static Future<void> markSessionCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstSessionCompletedKey, true);
    } catch (_) {}
  }

  static Future<void> _ensureLoaded({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (kIsWeb) return;
    if (!_enabled) return;
    if (interstitialAdUnitId.isEmpty || interstitialAdUnitId.contains('xxxx'))
      return;
    if (_interstitialAd != null) return;

    await loadInterstitialAd();

    // Wait a bit for onAdLoaded callback to populate _interstitialAd.
    if (_loadCompleter != null) {
      try {
        await _loadCompleter!.future.timeout(timeout);
      } catch (_) {
        // ignore timeout; caller will check _interstitialAd
      }
    } else {
      // No completer means loadInterstitialAd exited early; give it one more tick.
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
  }

  /// Load an interstitial so it's ready to show. Retries once on failure (code 0 or 3).
  static Future<void> loadInterstitialAd() async {
    if (kIsWeb) return;
    if (!_enabled) return;
    if (_interstitialAd != null || _isLoading) return;
    if (interstitialAdUnitId.isEmpty || interstitialAdUnitId.contains('xxxx')) {
      return;
    }
    _isLoading = true;
    _loadCompleter ??= Completer<void>();
    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isLoading = false;
            _retryDone = false;
            _loadCompleter?.complete();
            _loadCompleter = null;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                _markInterstitialShownNow();
              },
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
            _loadCompleter?.completeError(error);
            _loadCompleter = null;
            if (!_retryDone && (error.code == 0 || error.code == 3)) {
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
      _loadCompleter?.completeError(e);
      _loadCompleter = null;
    }
  }

  /// Show the interstitial. Call after a natural break (e.g. after user downloads an image).
  /// Returns true if ad was shown, false if not ready or ID not set.
  static Future<bool> showInterstitialAd() async {
    if (kIsWeb) return false;
    if (!_enabled) return false;
    if (interstitialAdUnitId.isEmpty || interstitialAdUnitId.contains('xxxx')) {
      return false;
    }
    // Ensure the ad is loaded before trying to show it.
    if (_interstitialAd == null) {
      await _ensureLoaded();
      if (_interstitialAd == null) return false;
    }
    final ad = _interstitialAd!;
    _interstitialAd = null;
    await ad.show();
    return true;
  }

  /// [generationsTodayForPacing] = count in the **current rolling 24h window** **after**
  /// [GenerationLimitService.recordGeneration] (see [GenerationLimitService.getGenerationsTodayForAdPacing]).
  static Future<bool> shouldShowAfterGenerationBreak({
    required int generationsTodayForPacing,
    Duration? cooldown,
  }) async {
    if (kIsWeb) return false;
    if (!_enabled) return false;

    final firstAfter = EnvConstants.adsInterstitialFirstAfterPerDay;
    final everyN = EnvConstants.adsInterstitialEveryNAfterFirst;
    final effectiveCooldown =
        cooldown ??
        Duration(seconds: EnvConstants.adsInterstitialCooldownSeconds);

    if (firstAfter <= 0 || everyN <= 0) return false;
    if (generationsTodayForPacing < firstAfter) return false;

    final bool atMilestone;
    if (generationsTodayForPacing == firstAfter) {
      atMilestone = true;
    } else {
      atMilestone = (generationsTodayForPacing - firstAfter) % everyN == 0;
    }

    if (!atMilestone) return false;

    // Growth-first: never show interstitial in user's first app session.
    try {
      final prefs = await SharedPreferences.getInstance();
      final firstSessionCompleted =
          prefs.getBool(_firstSessionCompletedKey) ?? false;
      if (!firstSessionCompleted) {
        return false;
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastMs = prefs.getInt(_lastShownMsKey) ?? 0;
      final nowMs = await ServerClock.nowMs();
      return nowMs - lastMs >= effectiveCooldown.inMilliseconds;
    } catch (_) {
      return true;
    }
  }
}
