import 'package:flutter/material.dart';
import 'package:genwalls/Model/utils/Routes/routes_name.dart';
import 'package:genwalls/view/Auth/ForgotScreen/forgot_screen.dart';
import 'package:genwalls/view/Auth/SignIn/sign_in.dart';
import 'package:genwalls/view/Auth/SignUp/sign_up.dart';
import 'package:genwalls/view/BottomNavigation/bottom_nav_screen.dart';
import 'package:genwalls/view/Home/home.dart';
import 'package:genwalls/view/ImageCreated/image_created_screen.dart';
import 'package:genwalls/view/ImageGenerate/image_generate_screen.dart';
import 'package:genwalls/view/OnBoardingScreen/indicator_Screen.dart';
import 'package:genwalls/view/OnBoardingScreen/on_boarding_screen.dart';
import 'package:genwalls/view/ProfileScreen/profile_screen.dart';
import 'package:genwalls/view/SplahScrren/splash_screen.dart';
import 'package:genwalls/view/Verification/verification.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.SplashScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
      case RoutesName.IndicatorScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const IndicatorScreen(),
        );
      case RoutesName.OnboardingScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OnboardingScreen(),
        );
      case RoutesName.SignUpScreen:
        return MaterialPageRoute(settings: settings, builder: (_) => SignUp());
      case RoutesName.VerificationScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Verification(),
        );
      case RoutesName.SignInScreen:
        return MaterialPageRoute(settings: settings, builder: (_) => SignIn());
      case RoutesName.ForgotScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ForgotScreen(),
        );
      case RoutesName.HomeScreen:
        return MaterialPageRoute(settings: settings, builder: (_) => Home());
      case RoutesName.ImageGenerateScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ImageGenerateScreen(),
        );
      case RoutesName.ImageCreatedScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ImageCreatedScreen(),
        );
      case RoutesName.ProfileScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProfileScreen(),
        );
      case RoutesName.BottomNavScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BottomNavScreen(),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            body: Stack(
              children: [
                const Center(
                  child: Text(
                    'No Route Found',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Times',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: InkWell(
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}
