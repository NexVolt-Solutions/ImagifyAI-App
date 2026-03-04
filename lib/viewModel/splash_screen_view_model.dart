import 'package:flutter/material.dart';
import 'package:imagifyai/Core/services/token_storage_service.dart';
import 'package:imagifyai/Core/utils/Routes/routes_name.dart';
import 'package:imagifyai/viewModel/sign_in_view_model.dart';
import 'package:provider/provider.dart';

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

    await Future.delayed(const Duration(milliseconds: 800));

    if (!context.mounted) return;
    if (isLoggedIn) {
      // Ensure SignInViewModel has loaded tokens from storage before opening Home,
      // so accessToken is available and we don't see "Missing" then fallback to storage.
      await context.read<SignInViewModel>().ensureTokensLoaded();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, RoutesName.BottomNavScreen);
      }
    } else {
      bool onboardingCompleted = false;
      try {
        onboardingCompleted =
            await TokenStorageService.isOnboardingCompleted();
      } catch (e) {
        // ignore
      }

      if (context.mounted) {
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
  }
}
