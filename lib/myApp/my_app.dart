import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/utils/Routes/routes.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/viewModel/bottom_nav_screen_view_model.dart';
import 'package:genwalls/viewModel/home_view_model.dart';
import 'package:genwalls/viewModel/image_generate_view_model.dart';
import 'package:genwalls/viewModel/on_boarding_screen_view_model.dart';
import 'package:genwalls/viewModel/sign_in_view_model.dart';
import 'package:genwalls/viewModel/sign_up_view_model.dart';
import 'package:genwalls/viewModel/splash_screen_view_model.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(375, 812), // Figma / Design size
      splitScreenMode: true,
      builder: (context, child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => SplashScreenViewModel()),
          ChangeNotifierProvider(
            create: (context) => OnBoardingScreenViewModel(),
          ),
          ChangeNotifierProvider(create: (context) => SignUpViewModel()),
          ChangeNotifierProvider(create: (context) => SignInViewModel()),
          ChangeNotifierProvider(create: (context) => HomeViewModel()),
          ChangeNotifierProvider(
            create: (context) => BottomNavScreenViewModel(),
          ),
          ChangeNotifierProvider(create: (context) => ImageGenerateViewModel()),
          ChangeNotifierProvider(create: (context) => SignUpViewModel()),
        ],
        child: MaterialApp(
          initialRoute: RoutesName.SplashScreen,
          onGenerateRoute: Routes.generateRoute,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
