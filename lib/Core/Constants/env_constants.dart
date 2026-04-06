import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment-based constants. Load .env in main() before using.
/// Values come from assets/env/default.env (see .env.example for a copy-paste template).
class EnvConstants {
  EnvConstants._();

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.imagifyai.io/api/v1';

  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ??
      '687032857486-dtgppeu5qk5jfb7ckocrakqsddh8kd67.apps.googleusercontent.com';

  static String get admobAppId =>
      dotenv.env['ADMOB_APP_ID'] ?? 'ca-app-pub-8279839772210876~1156823788';

  static String get admobRewardedAdUnitId =>
      dotenv.env['ADMOB_REWARDED_AD_UNIT_ID'] ??
      'ca-app-pub-8279839772210876/9867177613';

  static String get admobInterstitialAdUnitId =>
      dotenv.env['ADMOB_INTERSTITIAL_AD_UNIT_ID'] ??
      'ca-app-pub-8279839772210876/7688095622';

  static String get admobBannerAdUnitId =>
      dotenv.env['ADMOB_BANNER_AD_UNIT_ID'] ??
      'ca-app-pub-8279839772210876/6515639825';

  /// Growth-first toggle: disable interstitials to protect retention.
  /// Set ADS_ENABLE_INTERSTITIAL=true in .env to re-enable later.
  static bool get adsEnableInterstitial =>
      (dotenv.env['ADS_ENABLE_INTERSTITIAL'] ?? 'false').toLowerCase() ==
      'true';

  /// Interstitial pacing controls (remote-friendly via .env / Remote Config sync).
  static int get adsInterstitialEveryNGenerations =>
      int.tryParse(dotenv.env['ADS_INTERSTITIAL_EVERY_N'] ?? '') ?? 5;

  static int get adsInterstitialCooldownSeconds =>
      int.tryParse(dotenv.env['ADS_INTERSTITIAL_COOLDOWN_SECONDS'] ?? '') ??
      120;
}
