import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imagifyai/Core/services/token_storage_service.dart';
import 'package:imagifyai/Core/utils/Routes/routes_name.dart';

class SplashScreenViewModel extends ChangeNotifier {
  void splashService(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 500));

    bool isLoggedIn = false;
    try {
      isLoggedIn = await TokenStorageService.isLoggedIn();
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        isLoggedIn = await TokenStorageService.isLoggedIn();
      } catch (retryError) {
        // If still fails, assume not logged in
        isLoggedIn = false;
      }
    }

    Future.delayed(const Duration(seconds: 3), () async {
      if (context.mounted) {
        if (isLoggedIn) {
          // User is logged in, navigate to home screen
          if (kDebugMode) {
            print('=== SPLASH SCREEN: USER IS LOGGED IN ===');
            print('Navigating to BottomNavScreen (Home)...');
          }
          Navigator.pushReplacementNamed(context, RoutesName.BottomNavScreen);
        } else {
          // Check if onboarding has been completed
          bool onboardingCompleted = false;
          try {
            onboardingCompleted =
                await TokenStorageService.isOnboardingCompleted();
          } catch (e) {
            if (kDebugMode) {
              print('Error checking onboarding status: $e');
            }
          }

          if (onboardingCompleted) {
            // Onboarding completed, navigate to sign in screen
            if (kDebugMode) {
              print('=== SPLASH SCREEN: ONBOARDING COMPLETED ===');
              print('Navigating to SignInScreen...');
            }
            Navigator.pushReplacementNamed(context, RoutesName.SignInScreen);
          } else {
            // Onboarding not completed, show onboarding screen
            if (kDebugMode) {
              print('=== SPLASH SCREEN: ONBOARDING NOT COMPLETED ===');
              print('Navigating to OnboardingScreen...');
            }
            Navigator.pushReplacementNamed(
              context,
              RoutesName.OnboardingScreen,
            );
          }
        }
      }
    });
  }
}
