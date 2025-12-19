import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/services/token_storage_service.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/Core/utils/jwt_decoder.dart';
import 'package:genwalls/Core/utils/snackbar_util.dart';
import 'package:genwalls/models/auth/logout_response.dart';
import 'package:genwalls/models/auth/login_response.dart';
import 'package:genwalls/models/auth/refresh_response.dart';
import 'package:genwalls/repositories/auth_repository.dart';

class SignInViewModel extends ChangeNotifier {
  SignInViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    _loadTokensFromStorage();
  }

  final AuthRepository _authRepository;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool rememberMe = true;
  String? _refreshToken;
  String? _accessToken;

  String? get accessToken => _accessToken;

  void toggleRemember(bool? value) {
    rememberMe = value ?? false;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    if (isLoading) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (password.isEmpty) {
      _showMessage(context, 'Password is required');
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final LoginResponse response = await _authRepository.login(
        email: email,
        password: password,
      );

      final message = response.message ?? 'Logged in successfully';
      _refreshToken = response.refreshToken;
      _accessToken = response.accessToken;
      
      if (kDebugMode) {
        print('=== LOGIN SUCCESSFUL ===');
        print('Access token received: ${_accessToken != null && _accessToken!.isNotEmpty}');
        print('Refresh token received: ${_refreshToken != null && _refreshToken!.isNotEmpty}');
        print('Access token length: ${_accessToken?.length ?? 0}');
        print('Login response data: ${response.data}');
        
        // Check login response for user_id
        String? userIdFromResponse;
        if (response.data != null) {
          print('Data type: ${response.data.runtimeType}');
          if (response.data is Map) {
            final dataMap = response.data as Map;
            print('Data keys: ${dataMap.keys.toList()}');
            userIdFromResponse = dataMap['id']?.toString();
            print('User ID in data: $userIdFromResponse');
          }
        }
        
        // Try to extract user_id from JWT token
        String? userIdFromJwt;
        if (_accessToken != null && _accessToken!.isNotEmpty) {
          try {
            final decoded = JwtDecoder.decode(_accessToken!);
            if (decoded != null) {
              print('=== JWT TOKEN PAYLOAD ===');
              print('JWT Payload keys: ${decoded.keys.toList()}');
              print('JWT Payload: $decoded');
              
              // Try to get user_id from JWT
              userIdFromJwt = decoded['user_id']?.toString() ?? 
                             decoded['userId']?.toString() ?? 
                             decoded['id']?.toString();
              
              if (userIdFromJwt != null) {
                print('✅ User ID found in JWT: $userIdFromJwt');
              } else {
                print('❌ User ID NOT found in JWT');
                print('JWT only contains: ${decoded.keys.toList()}');
                if (decoded.containsKey('sub')) {
                  print('⚠️  JWT contains "sub" field: ${decoded['sub']}');
                  print('⚠️  "sub" appears to be email, not user_id');
                }
              }
            }
          } catch (e) {
            print('❌ Failed to decode JWT: $e');
          }
        }
        
        // Save user_id if found in either response or JWT
        final userIdToSave = userIdFromResponse ?? userIdFromJwt;
        if (userIdToSave != null && userIdToSave.isNotEmpty) {
          await TokenStorageService.saveUserId(userIdToSave);
          if (kDebugMode) {
            print('✅ User ID saved to storage: $userIdToSave');
            print('   Source: ${userIdFromResponse != null ? "Login Response" : "JWT Token"}');
          }
        } else {
          print('❌ CRITICAL: User ID not found in login response or JWT token!');
          print('❌ Cannot fetch user profile without user_id');
          print('❌ Backend needs to either:');
          print('   1. Include user_id in login response, OR');
          print('   2. Include user_id in JWT token payload, OR');
          print('   3. Support /users/me endpoint');
        }
      }
      
      // Save tokens to SharedPreferences
      if (_accessToken != null && _refreshToken != null) {
        await TokenStorageService.saveTokens(_accessToken!, _refreshToken!);
      }
      
      notifyListeners(); // Notify listeners so Provider updates with new token
      _showMessage(context, message, isError: false);
      Navigator.pushNamed(context, RoutesName.BottomNavScreen);
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (_) {
      errorMessage = 'Hmm, something unexpected happened. Let\'s try that again!';
      _showMessage(context, errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshSession(BuildContext context) async {
    if (isLoading) return;
    if ((_refreshToken ?? '').isEmpty) {
      _showMessage(context, 'No refresh token available. Please login again.');
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final RefreshResponse response = await _authRepository.refreshToken(
        refreshToken: _refreshToken!,
      );
      _refreshToken = response.refreshToken ?? _refreshToken;
      _accessToken = response.accessToken ?? _accessToken;
      
      // Save updated tokens to SharedPreferences
      if (_accessToken != null && _refreshToken != null) {
        await TokenStorageService.saveTokens(_accessToken!, _refreshToken!);
      }
      
      final message = response.message ?? 'Session refreshed';
      _showMessage(context, message, isError: false);
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (_) {
      errorMessage = 'Hmm, something unexpected happened. Let\'s try that again!';
      _showMessage(context, errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    if (isLoading) return;
    if ((_refreshToken ?? '').isEmpty) {
      _showMessage(context, 'No refresh token available. Please login again.');
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final LogoutResponse response =
          await _authRepository.signOut(refreshToken: _refreshToken!);
      final message = response.message ?? 'Logged out successfully';
      _showMessage(context, message, isError: false);
      _refreshToken = null;
      _accessToken = null;
      
      // Clear tokens from SharedPreferences
      await TokenStorageService.clearTokens();
      
      emailController.clear();
      passwordController.clear();
      notifyListeners();
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.SignInScreen,
        (route) => false,
      );
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (_) {
      errorMessage = 'Hmm, something unexpected happened. Let\'s try that again!';
      _showMessage(context, errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load tokens from SharedPreferences on initialization
  Future<void> _loadTokensFromStorage() async {
    try {
      // Wait a bit to ensure platform channels are ready
      await Future.delayed(const Duration(milliseconds: 300));
      
      final accessToken = await TokenStorageService.getAccessToken();
      final refreshToken = await TokenStorageService.getRefreshToken();
      
      if (accessToken != null && refreshToken != null) {
        _accessToken = accessToken;
        _refreshToken = refreshToken;
        
        if (kDebugMode) {
          print('=== TOKENS LOADED FROM STORAGE ===');
          print('Access token loaded: ${_accessToken != null && _accessToken!.isNotEmpty}');
          print('Refresh token loaded: ${_refreshToken != null && _refreshToken!.isNotEmpty}');
        }
        
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading tokens from storage: $e');
        // Retry once after a delay
        try {
          await Future.delayed(const Duration(milliseconds: 500));
          final accessToken = await TokenStorageService.getAccessToken();
          final refreshToken = await TokenStorageService.getRefreshToken();
          
          if (accessToken != null && refreshToken != null) {
            _accessToken = accessToken;
            _refreshToken = refreshToken;
            notifyListeners();
            if (kDebugMode) {
              print('Retry successful - tokens loaded');
            }
          }
        } catch (retryError) {
          if (kDebugMode) {
            print('Retry also failed: $retryError');
          }
        }
      }
    }
  }

  void _showMessage(BuildContext context, String message, {bool isError = true}) {
    SnackbarUtil.showTopSnackBar(context, message, isError: isError);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
