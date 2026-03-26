import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:imagifyai/Core/Constants/env_constants.dart';

/// Simple reusable AdMob banner for high-traffic screens.
/// In debug it always uses Google test banner ID.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;

  String get _adUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    return EnvConstants.admobBannerAdUnitId;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBanner();
    });
  }

  Future<void> _loadBanner() async {
    // Guard: if banner unit is not configured in release, skip rendering.
    if (_adUnitId.isEmpty || _adUnitId.contains('xxxx') || _isLoading) return;
    _isLoading = true;

    final width = MediaQuery.sizeOf(context).width.truncate();
    final adSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || adSize == null) {
      _isLoading = false;
      return;
    }

    final ad = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: adSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
          _isLoading = false;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isLoading = false;
        },
      ),
    );

    await ad.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      child: Center(
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }
}
