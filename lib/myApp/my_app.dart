import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Model/utils/Routes/routes.dart';
import 'package:genwalls/Model/utils/Routes/routes_name.dart';
import 'package:genwalls/Model/viewModel/bottom_nav_screen_view_model.dart';
import 'package:genwalls/Model/viewModel/home_view_model.dart';
import 'package:genwalls/Model/viewModel/image_generate_view_model.dart';
import 'package:genwalls/Model/viewModel/on_boarding_screen_view_model.dart';
import 'package:genwalls/Model/viewModel/sign_in_view_model.dart';
import 'package:genwalls/Model/viewModel/sign_up_view_model.dart';
import 'package:genwalls/Model/viewModel/splash_screen_view_model.dart';
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
      designSize: const Size(360, 690),
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
