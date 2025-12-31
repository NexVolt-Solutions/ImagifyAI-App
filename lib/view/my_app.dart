import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/services/token_storage_service.dart';
import 'package:genwalls/Core/utils/Routes/routes.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/Core/theme/app_theme.dart';
import 'package:genwalls/repositories/auth_repository.dart';
import 'package:genwalls/viewModel/bottom_nav_screen_view_model.dart';
import 'package:genwalls/viewModel/edit_profile_view_model.dart';
import 'package:genwalls/viewModel/library_view_model.dart';
import 'package:genwalls/viewModel/forgot_password_view_model.dart';
import 'package:genwalls/viewModel/home_view_model.dart';
import 'package:genwalls/viewModel/image_created_view_model.dart';
import 'package:genwalls/viewModel/image_generate_view_model.dart';
import 'package:genwalls/viewModel/on_boarding_screen_view_model.dart';
import 'package:genwalls/viewModel/profile_screen_view_model.dart';
import 'package:genwalls/viewModel/sign_in_view_model.dart';
import 'package:genwalls/viewModel/sign_up_view_model.dart';
import 'package:genwalls/viewModel/splash_screen_view_model.dart';
import 'package:genwalls/viewModel/theme_provider.dart';
import 'package:genwalls/viewModel/verification_view_model.dart';
import 'package:genwalls/viewModel/forgor_verification_view_model.dart';
import 'package:genwalls/viewModel/set_new_password_view_model.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Ensure token refresh callback is set (backup in case hot reload reset it)
    _setupTokenRefresh();
  }

  void _setupTokenRefresh() {
    // Set up automatic token refresh callback for ApiService
    ApiService.setTokenRefreshCallback(() async {
      if (kDebugMode) {
        print('🔄 Token refresh callback invoked');
      }
      try {
        // Get refresh token from storage
        final refreshToken = await TokenStorageService.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          if (kDebugMode) {
            print('❌ No refresh token available in storage');
          }
          return null;
        }

        if (kDebugMode) {
          print('✅ Refresh token found, calling refresh API...');
        }

        // Refresh the token using AuthRepository
        final authRepository = AuthRepository();
        final response = await authRepository.refreshToken(
          refreshToken: refreshToken,
        );

        // Save new tokens
        if (response.accessToken != null && response.refreshToken != null) {
          await TokenStorageService.saveTokens(
            response.accessToken!,
            response.refreshToken!,
          );
          if (kDebugMode) {
            print('✅ New tokens saved successfully');
          }
          return response.accessToken;
        }

        if (kDebugMode) {
          print('❌ Refresh response missing tokens');
        }
        return null;
      } catch (e) {
        if (kDebugMode) {
          print('❌ Token refresh failed: $e');
        }
        // Token refresh failed
        return null;
      }
    });
    
    if (kDebugMode) {
      // Verify the callback was actually set
      final isSet = ApiService.hasTokenRefreshCallback;
      print('✅ Token refresh callback setup in MyApp.initState()');
      print('   Callback is set: $isSet');
      if (!isSet) {
        print('   ⚠️  WARNING: Callback is still null after setup!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Provider - should be first to be available to all other providers
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => SplashScreenViewModel()),
        ChangeNotifierProvider(
          create: (context) => OnBoardingScreenViewModel(),
        ),
        ChangeNotifierProvider(create: (context) => SignUpViewModel()),
        ChangeNotifierProvider(create: (context) => SignInViewModel()),
        ChangeNotifierProvider(create: (context) => ForgotPasswordViewModel()),
        ChangeNotifierProvider(create: (context) => VerificationViewModel()),
        ChangeNotifierProvider(create: (context) => ForgorVerificationViewModel()),
        ChangeNotifierProvider(create: (context) => SetNewPasswordViewModel()),
        ChangeNotifierProvider(create: (context) => LibraryViewModel()),
        ChangeNotifierProvider(create: (context) => HomeViewModel()),
        ChangeNotifierProvider(create: (context) => BottomNavScreenViewModel()),
        ChangeNotifierProvider(create: (context) => ImageGenerateViewModel()),
        ChangeNotifierProvider(create: (context) => ImageCreatedViewModel()),
        ChangeNotifierProvider(create: (context) => ProfileScreenViewModel()),
        ChangeNotifierProvider(create: (context) => EditProfileViewModel()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Genwalls',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: RoutesName.SplashScreen,
            onGenerateRoute: Routes.generateRoute,
          );
        },
      ),
    );
  }
}
