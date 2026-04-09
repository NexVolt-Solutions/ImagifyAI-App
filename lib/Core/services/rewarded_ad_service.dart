import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:imagifyai/Core/Constants/env_constants.dart';

/// AdMob rewarded ad. Quota is granted via **SSV** on the server; the app only refreshes usage.
///
/// Pass [serverSideVerificationUserId] (your backend user id) so AdMob can include it in the SSV callback.
/// Ad unit ID from .env (ADMOB_REWARDED_AD_UNIT_ID). In debug, uses Google test ID so ads always load.
class RewardedAdService {
  static String get rewardedAdUnitId =>
      kDebugMode
          ? 'ca-app-pub-3940256099942544/5224354917' // Google test rewarded
          : EnvConstants.admobRewardedAdUnitId;

  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;
  static bool _retryDone = false;

  /// Load a rewarded ad so it's ready to show. Retries once on failure (code 0 or 3).
  static Future<void> loadRewardedAd() async {
    if (kIsWeb) return;
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

  /// Show the rewarded ad. [onReward] runs when the user earns the reward (then poll server for SSV).
  ///
  /// Set [serverSideVerificationUserId] before show so SSV callbacks can identify the user.
  ///
  /// [onFullscreenAdEnded] runs when the ad leaves fullscreen (dismissed or failed to show).
  /// Use it to dismiss overlays if [onUserEarnedReward] never fires (e.g. user closed early).
  /// Returns true if show was invoked, false if not ready.
  static Future<bool> showRewardedAd({
    Future<void> Function()? onReward,
    String? serverSideVerificationUserId,
    VoidCallback? onFullscreenAdEnded,
  }) async {
    if (kIsWeb) return false;
    if (_rewardedAd == null) {
      await loadRewardedAd();
      if (_rewardedAd == null) return false;
    }
    final ad = _rewardedAd!;
    _rewardedAd = null;

    final uid = serverSideVerificationUserId;
    if (uid != null && uid.isNotEmpty) {
      try {
        await ad.setServerSideOptions(
          ServerSideVerificationOptions(userId: uid),
        );
      } catch (_) {}
    }

    final prev = ad.fullScreenContentCallback;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: prev?.onAdShowedFullScreenContent,
      onAdImpression: prev?.onAdImpression,
      onAdDismissedFullScreenContent: (RewardedAd a) {
        onFullscreenAdEnded?.call();
        prev?.onAdDismissedFullScreenContent?.call(a);
      },
      onAdFailedToShowFullScreenContent: (RewardedAd a, AdError e) {
        onFullscreenAdEnded?.call();
        prev?.onAdFailedToShowFullScreenContent?.call(a, e);
      },
    );

    ad.show(
      onUserEarnedReward: (_, __) {
        final f = onReward;
        if (f != null) {
          f().catchError((_) {});
        }
      },
    );
    return true;
  }
}
