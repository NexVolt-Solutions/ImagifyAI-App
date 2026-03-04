import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:imagifyai/Core/services/analytics_service.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/Core/services/firebase_analytics_delegate.dart';
import 'package:imagifyai/Core/services/local_notification_service.dart';
import 'package:imagifyai/Core/services/interstitial_ad_service.dart';
import 'package:imagifyai/Core/services/rewarded_ad_service.dart';
import 'package:imagifyai/Core/services/token_storage_service.dart';
import 'package:imagifyai/firebase_options.dart';
import 'package:imagifyai/repositories/auth_repository.dart';
import 'package:imagifyai/view/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AnalyticsService.delegate = FirebaseAnalyticsDelegate();
  await LocalNotificationService.initialize();
  await MobileAds.instance.initialize();

  // Only in debug: use test device IDs so test ads show; never in release (Play Store).
  if (kDebugMode) {
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: [
          '26FF934A589AEA5FF1D9F910862DC114', // Add more from log if needed.
        ],
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 1500));
  }

  RewardedAdService.loadRewardedAd();
  InterstitialAdService.loadInterstitialAd();
  _setupTokenRefresh();
  runApp(const MyApp());
}

void _setupTokenRefresh() {
  // Set up automatic token refresh callback for ApiService
  ApiService.setTokenRefreshCallback(() async {
    try {
      final refreshToken = await TokenStorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      final authRepository = AuthRepository();
      final response = await authRepository.refreshToken(
        refreshToken: refreshToken,
      );

      if (response.accessToken != null && response.refreshToken != null) {
        await TokenStorageService.saveTokens(
          response.accessToken!,
          response.refreshToken!,
        );
        return response.accessToken;
      }

      return null;
    } catch (e) {
      return null;
    }
  });
}
