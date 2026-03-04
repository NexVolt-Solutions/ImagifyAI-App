import 'package:flutter/material.dart';
import 'package:imagifyai/Core/services/token_storage_service.dart';
import 'package:imagifyai/Core/utils/Routes/routes_name.dart';
import 'package:imagifyai/viewModel/sign_in_view_model.dart';
import 'package:provider/provider.dart';

class SplashScreenViewModel extends ChangeNotifier {
  /// Minimum time to show splash so it doesn't flash; keep short for faster feel.
  static const Duration _minSplashDuration = Duration(milliseconds: 400);

  void splashService(BuildContext context) async {
    // Run storage checks and minimum display time in parallel so we don't add
    // unnecessary delay on top of actual work.
    final results = await Future.wait(<Future<dynamic>>[
      Future.delayed(_minSplashDuration),
      _getLoginAndOnboardingState(),
    ]);
    final state = results[1] as _SplashState;

    if (!context.mounted) return;
    if (state.isLoggedIn) {
      await context.read<SignInViewModel>().ensureTokensLoaded();
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, RoutesName.BottomNavScreen);
    } else {
      if (!context.mounted) return;
      if (state.onboardingCompleted) {
        Navigator.pushReplacementNamed(context, RoutesName.SignInScreen);
      } else {
        Navigator.pushReplacementNamed(context, RoutesName.OnboardingScreen);
      }
    }
  }

  Future<_SplashState> _getLoginAndOnboardingState() async {
    bool isLoggedIn = false;
    bool onboardingCompleted = false;
    try {
      isLoggedIn = await TokenStorageService.isLoggedIn();
      if (!isLoggedIn) {
        onboardingCompleted = await TokenStorageService.isOnboardingCompleted();
      }
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 200));
        isLoggedIn = await TokenStorageService.isLoggedIn();
        if (!isLoggedIn) {
          onboardingCompleted =
              await TokenStorageService.isOnboardingCompleted();
        }
      } catch (_) {
        // Assume not logged in, show onboarding/sign-in
      }
    }
    return _SplashState(
      isLoggedIn: isLoggedIn,
      onboardingCompleted: onboardingCompleted,
    );
  }
}

class _SplashState {
  const _SplashState({
    required this.isLoggedIn,
    required this.onboardingCompleted,
  });
  final bool isLoggedIn;
  final bool onboardingCompleted;
}
