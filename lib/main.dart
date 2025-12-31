import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/services/token_storage_service.dart';
import 'package:genwalls/repositories/auth_repository.dart';
import 'package:genwalls/view/my_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set up token refresh callback before running the app
  _setupTokenRefresh();
  runApp(const MyApp());
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
    print('✅ Token refresh callback has been set up in main()');
    print('   Callback is set: $isSet');
    if (!isSet) {
      print('   ⚠️  ERROR: Callback is null after setup in main()!');
    }
  }
}
