import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genwalls/Core/services/token_storage_service.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';

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
    
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        if (isLoggedIn) {
          // User is logged in, navigate to home screen
          if (kDebugMode) {
            print('=== SPLASH SCREEN: USER IS LOGGED IN ===');
            print('Navigating to BottomNavScreen (Home)...');
          }
          Navigator.pushReplacementNamed(context, RoutesName.BottomNavScreen);
        } else {
          // User is not logged in, navigate to onboarding
          if (kDebugMode) {
            print('=== SPLASH SCREEN: USER IS NOT LOGGED IN ===');
            print('Navigating to OnboardingScreen...');
          }
          Navigator.pushReplacementNamed(context, RoutesName.OnboardingScreen);
        }
      }
    });
  }
}
