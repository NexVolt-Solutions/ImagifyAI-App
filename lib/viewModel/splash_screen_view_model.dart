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

    Future.delayed(const Duration(milliseconds: 800), () async {
      if (context.mounted) {
        if (isLoggedIn) {
          Navigator.pushReplacementNamed(context, RoutesName.BottomNavScreen);
        } else {
          bool onboardingCompleted = false;
          try {
            onboardingCompleted =
                await TokenStorageService.isOnboardingCompleted();
          } catch (e) {
            // ignore
          }

          if (onboardingCompleted) {
            Navigator.pushReplacementNamed(context, RoutesName.SignInScreen);
          } else {
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
