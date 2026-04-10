import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:imagifyai/Core/Constants/env_constants.dart';

class RewardedAdService {
  static String get rewardedAdUnitId => kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917'
      : EnvConstants.admobRewardedAdUnitId;

  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;
  static bool _retryDone = false;

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('[RewardedAd] $message');
    }
  }

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
            _log('loaded successfully (unit: $rewardedAdUnitId)');
            _rewardedAd = ad;
            _isLoading = false;
            _retryDone = false;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                _log('dismissed (preload next)');
                ad.dispose();
                _rewardedAd = null;
                loadRewardedAd(); // Preload next
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                _log(
                  'failed to show (preload callback): ${error.message} '
                  '(code=${error.code} domain=${error.domain})',
                );
                ad.dispose();
                _rewardedAd = null;
                _isLoading = false;
              },
            );
          },
          onAdFailedToLoad: (error) {
            _log(
              'failed to load: ${error.message} '
              '(code=${error.code} domain=${error.domain})',
            );
            _isLoading = false;
            if (!_retryDone && (error.code == 0 || error.code == 3)) {
              _retryDone = true;
              _log('scheduling retry in 3s (codes 0/3)');
              Future<void>.delayed(const Duration(seconds: 3), () {
                loadRewardedAd();
              });
            } else {
              _log('no retry (already retried or non-retry code)');
            }
          },
        ),
      );
    } catch (e, st) {
      _isLoading = false;
      _log('load threw: $e\n$st');
    }
  }

  static Future<bool> showRewardedAd({
    Future<void> Function()? onReward,
    String? serverSideVerificationUserId,
    VoidCallback? onFullscreenAdEnded,
  }) async {
    if (kIsWeb) return false;
    if (_rewardedAd == null) {
      _log('show: no cached ad, loading…');
      await loadRewardedAd();
      if (_rewardedAd == null) {
        _log('show: still not ready after load');
        return false;
      }
    }
    final ad = _rewardedAd!;
    _rewardedAd = null;

    final uid = serverSideVerificationUserId;
    if (uid != null && uid.isNotEmpty) {
      try {
        await ad.setServerSideOptions(
          ServerSideVerificationOptions(userId: uid),
        );
        _log('SSV userId set (len=${uid.length})');
      } catch (e) {
        _log('setServerSideOptions failed: $e');
      }
    } else {
      _log('show: no SSV userId');
    }

    final prev = ad.fullScreenContentCallback;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd a) {
        _log('fullscreen shown');
        prev?.onAdShowedFullScreenContent?.call(a);
      },
      onAdImpression: (RewardedAd a) {
        _log('impression recorded');
        prev?.onAdImpression?.call(a);
      },
      onAdDismissedFullScreenContent: (RewardedAd a) {
        _log('dismissed');
        onFullscreenAdEnded?.call();
        prev?.onAdDismissedFullScreenContent?.call(a);
      },
      onAdFailedToShowFullScreenContent: (RewardedAd a, AdError e) {
        _log(
          'failed to show: ${e.message} (code=${e.code} domain=${e.domain})',
        );
        onFullscreenAdEnded?.call();
        prev?.onAdFailedToShowFullScreenContent?.call(a, e);
      },
    );

    _log('invoking ad.show()');
    ad.show(
      onUserEarnedReward: (ad, reward) {
        _log('user earned reward: amount=${reward.amount} type=${reward.type}');
        final f = onReward;
        if (f != null) {
          f().catchError((_) {});
        }
      },
    );
    return true;
  }
}
