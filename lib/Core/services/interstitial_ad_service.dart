import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:imagifyai/Core/Constants/env_constants.dart';

/// AdMob Interstitial ad shown after natural breaks (e.g. after download).
/// Ad unit ID from .env (ADMOB_INTERSTITIAL_AD_UNIT_ID).
class InterstitialAdService {
  static String get interstitialAdUnitId =>
      EnvConstants.admobInterstitialAdUnitId;

  static InterstitialAd? _interstitialAd;
  static bool _isLoading = false;

  /// Load an interstitial so it's ready to show.
  static Future<void> loadInterstitialAd() async {
    if (_interstitialAd != null || _isLoading) return;
    if (interstitialAdUnitId.isEmpty || interstitialAdUnitId.contains('xxxx')) {
      return;
    }
    _isLoading = true;
    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isLoading = false;
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
    if (interstitialAdUnitId.isEmpty || interstitialAdUnitId.contains('xxxx')) return false;
    if (_interstitialAd == null) {
      await loadInterstitialAd();
      if (_interstitialAd == null) return false;
    }
    final ad = _interstitialAd!;
    _interstitialAd = null;
    await ad.show();
    return true;
  }
}
