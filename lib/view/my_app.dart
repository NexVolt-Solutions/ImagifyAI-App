import 'package:flutter/material.dart';
import 'package:genwalls/Core/utils/Routes/routes.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/viewModel/bottom_nav_screen_view_model.dart';
import 'package:genwalls/viewModel/library_view_model.dart';
import 'package:genwalls/viewModel/forgot_password_view_model.dart';
import 'package:genwalls/viewModel/home_view_model.dart';
import 'package:genwalls/viewModel/image_created_view_model.dart';
import 'package:genwalls/viewModel/image_generate_view_model.dart';
import 'package:genwalls/viewModel/on_boarding_screen_view_model.dart';
import 'package:genwalls/viewModel/sign_in_view_model.dart';
import 'package:genwalls/viewModel/sign_up_view_model.dart';
import 'package:genwalls/viewModel/splash_screen_view_model.dart';
import 'package:genwalls/viewModel/verification_view_model.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SplashScreenViewModel()),
        ChangeNotifierProvider(
          create: (context) => OnBoardingScreenViewModel(),
        ),
        ChangeNotifierProvider(create: (context) => SignUpViewModel()),
        ChangeNotifierProvider(create: (context) => SignInViewModel()),
        ChangeNotifierProvider(create: (context) => ForgotPasswordViewModel()),
        ChangeNotifierProvider(create: (context) => VerificationViewModel()),
        ChangeNotifierProvider(create: (context) => LibraryViewModel()),
        ChangeNotifierProvider(create: (context) => HomeViewModel()),
        ChangeNotifierProvider(create: (context) => BottomNavScreenViewModel()),
        ChangeNotifierProvider(create: (context) => ImageGenerateViewModel()),
        ChangeNotifierProvider(create: (context) => ImageCreatedViewModel()),
      ],
      child: MaterialApp(
        initialRoute: RoutesName.SplashScreen,
        onGenerateRoute: Routes.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
