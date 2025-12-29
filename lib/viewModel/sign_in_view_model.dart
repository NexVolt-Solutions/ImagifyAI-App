import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/services/token_storage_service.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/Core/utils/jwt_decoder.dart';
import 'package:genwalls/Core/utils/snackbar_util.dart';
import 'package:genwalls/models/auth/logout_response.dart';
import 'package:genwalls/models/auth/login_response.dart';
import 'package:genwalls/models/auth/refresh_response.dart';
import 'package:genwalls/repositories/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInViewModel extends ChangeNotifier {
  SignInViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    _loadTokensFromStorage();
    _loadRememberedEmail();
  }

  final AuthRepository _authRepository;

  // FormKey removed - should be created in widget state to avoid GlobalKey conflicts
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool rememberMe = true;
  String? _refreshToken;
  String? _accessToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  // Silent token refresh (without showing messages) - used for automatic token refresh
  Future<bool> refreshTokenSilently() async {
    // If refresh token is not in memory, try loading from storage
    if ((_refreshToken ?? '').isEmpty) {
      if (kDebugMode) {
        print('⚠️ Refresh token not in memory, trying to load from storage...');
      }
      try {
        final refreshTokenFromStorage = await TokenStorageService.getRefreshToken();
        if (refreshTokenFromStorage != null && refreshTokenFromStorage.isNotEmpty) {
          _refreshToken = refreshTokenFromStorage;
          if (kDebugMode) {
            print('✅ Refresh token loaded from storage');
          }
        } else {
          if (kDebugMode) {
            print('⚠️ No refresh token available for silent refresh');
          }
          return false;
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error loading refresh token from storage: $e');
        }
        return false;
      }
    }

    try {
      final RefreshResponse response = await _authRepository.refreshToken(
        refreshToken: _refreshToken!,
      );
      
      // Check if we got valid tokens
      if (response.accessToken == null || response.accessToken!.isEmpty) {
        if (kDebugMode) {
          print('❌ Refresh response missing access token');
        }
        // Clear invalid tokens
        _accessToken = null;
        _refreshToken = null;
        await TokenStorageService.clearTokens();
        notifyListeners();
        return false;
      }
      
      _refreshToken = response.refreshToken ?? _refreshToken;
      _accessToken = response.accessToken;
      
      // Save updated tokens to SharedPreferences
      if (_accessToken != null && _refreshToken != null) {
        await TokenStorageService.saveTokens(_accessToken!, _refreshToken!);
        
        // Save userId from refresh response if provided (preferred source)
        String? userIdToSave = response.userId;
        
        // If not in response, try to extract from JWT token
        if (userIdToSave == null || userIdToSave.isEmpty) {
          if (kDebugMode) {
            print('⚠️  User ID not in refresh response, extracting from new JWT...');
          }
          try {
            userIdToSave = JwtDecoder.getUserId(_accessToken!);
            if (userIdToSave != null && userIdToSave.isNotEmpty) {
              if (kDebugMode) {
                print('✅ User ID extracted from new JWT: $userIdToSave');
              }
            } else {
              if (kDebugMode) {
                print('❌ User ID not found in new JWT token');
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print('❌ Error extracting userId from new JWT: $e');
            }
          }
        } else {
          if (kDebugMode) {
            print('✅ User ID from refresh response: $userIdToSave');
          }
        }
        
        // Save userId if we found it (from response or JWT)
        if (userIdToSave != null && userIdToSave.isNotEmpty) {
          await TokenStorageService.saveUserId(userIdToSave);
          if (kDebugMode) {
            print('✅ User ID saved to storage: $userIdToSave');
          }
        } else {
          // If still no userId, check if we have one in storage already
          final existingUserId = await TokenStorageService.getUserId();
          if (existingUserId == null || existingUserId.isEmpty) {
            if (kDebugMode) {
              print('⚠️  Warning: No user ID available after token refresh');
            }
          } else {
            if (kDebugMode) {
              print('✅ Using existing user ID from storage: $existingUserId');
            }
          }
        }
      }
      
      if (kDebugMode) {
        print('✅ Token refreshed silently');
      }
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('❌ Failed to refresh token silently: ${e.message}');
        print('   Status code: ${e.statusCode}');
      }
      
      // Only clear tokens on authentication errors (401, 403), not server errors (500, 503, etc.)
      // Server errors might be temporary and we don't want to log the user out
      if (e.statusCode == 401 || e.statusCode == 403) {
        if (kDebugMode) {
          print('⚠️  Authentication error during refresh, clearing tokens...');
        }
        // Clear invalid tokens on authentication failure
        _accessToken = null;
        _refreshToken = null;
        await TokenStorageService.clearTokens();
        notifyListeners();
        return false;
      } else {
        // Server error (500, 503, etc.) - don't clear tokens, might be temporary
        if (kDebugMode) {
          print('⚠️  Server error during refresh (${e.statusCode}), keeping existing tokens');
          print('   This might be a temporary server issue');
        }
        // Don't clear tokens on server errors - they might still be valid
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error refreshing token silently: $e');
      }
      // For unexpected errors, don't clear tokens - might be network issues
      // Only clear if it's clearly an authentication issue
      return false;
    }
  }

  void toggleRemember(bool? value) {
    rememberMe = value ?? false;
    notifyListeners();
    
    // If "Remember Me" is unchecked, clear saved email
    if (!rememberMe) {
      TokenStorageService.clearRememberedEmail();
      if (kDebugMode) {
        print('✅ Remembered email cleared (Remember Me unchecked)');
      }
    }
  }

  Future<void> login(BuildContext context, {required GlobalKey<FormState> formKey}) async {
    if (isLoading) return;
    
    // Validate form - if validation fails, stop here
    if (formKey.currentState == null) {
      if (kDebugMode) {
        print('⚠️ Form key state is null');
      }
      return;
    }
    
    final isValid = formKey.currentState!.validate();
    if (!isValid) {
      if (kDebugMode) {
        print('❌ Form validation failed - preventing submission');
        print('Email: ${emailController.text.trim()}');
      }
      return;
    }

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
        
        // Extract user_id from login response (API returns it at root level)
        String? userIdFromResponse = response.userId;
        
        // Fallback: Try to extract user_id from JWT token if not in response
        String? userIdFromJwt;
        if (userIdFromResponse == null && _accessToken != null && _accessToken!.isNotEmpty) {
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
            print('=== USER ID SAVED ===');
            print('User ID: $userIdToSave');
            print('Saved: true');
            print('✅ User ID saved to storage: $userIdToSave');
            print('   Source: ${userIdFromResponse != null ? "Login Response" : "JWT Token"}');
          }
        } else {
          if (kDebugMode) {
            print('❌ CRITICAL: User ID not found in login response or JWT token!');
            print('❌ Cannot fetch user profile without user_id');
          }
        }
      }
      
      // Save tokens to SharedPreferences
      if (_accessToken != null && _refreshToken != null) {
        await TokenStorageService.saveTokens(_accessToken!, _refreshToken!);
      }
      
      // Save email if "Remember Me" is checked
      if (rememberMe) {
        await TokenStorageService.saveRememberedEmail(email);
        if (kDebugMode) {
          print('✅ Email saved for "Remember Me": $email');
        }
      } else {
        // Clear remembered email if "Remember Me" is unchecked
        await TokenStorageService.clearRememberedEmail();
        if (kDebugMode) {
          print('✅ Remembered email cleared (Remember Me unchecked)');
        }
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

  Future<void> signInWithGoogle(BuildContext context) async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Initialize Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Sign in with Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        isLoading = false;
        notifyListeners();
        return;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      if (kDebugMode) {
        print('=== GOOGLE SIGN-IN ===');
        print('User: ${googleUser.displayName}');
        print('Email: ${googleUser.email}');
        print('ID Token received: ${googleAuth.idToken != null}');
      }

      // Call backend API with Google credentials
      final LoginResponse response = await _authRepository.googleSignIn(
        idToken: googleAuth.idToken!,
        name: googleUser.displayName ?? googleUser.email,
        picture: googleUser.photoUrl,
      );

      final message = response.message ?? 'Logged in successfully';
      _refreshToken = response.refreshToken;
      _accessToken = response.accessToken;

      if (kDebugMode) {
        print('=== GOOGLE SIGN-IN SUCCESSFUL ===');
        print('Access token received: ${_accessToken != null && _accessToken!.isNotEmpty}');
        print('Refresh token received: ${_refreshToken != null && _refreshToken!.isNotEmpty}');
        print('Access token length: ${_accessToken?.length ?? 0}');

        // Extract user_id from login response (API returns it at root level)
        String? userIdFromResponse = response.userId;

        // Fallback: Try to extract user_id from JWT token if not in response
        String? userIdFromJwt;
        if (userIdFromResponse == null && _accessToken != null && _accessToken!.isNotEmpty) {
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
            print('=== USER ID SAVED ===');
            print('User ID: $userIdToSave');
            print('Saved: true');
            print('✅ User ID saved to storage: $userIdToSave');
            print('   Source: ${userIdFromResponse != null ? "Google Sign-In Response" : "JWT Token"}');
          }
        } else {
          if (kDebugMode) {
            print('❌ CRITICAL: User ID not found in Google sign-in response or JWT token!');
            print('❌ Cannot fetch user profile without user_id');
          }
        }
      }

      // Save tokens to SharedPreferences
      if (_accessToken != null && _refreshToken != null) {
        await TokenStorageService.saveTokens(_accessToken!, _refreshToken!);
      }

      // Save email for "Remember Me" (Google sign-in always remembers)
      if (googleUser.email.isNotEmpty) {
        await TokenStorageService.saveRememberedEmail(googleUser.email);
        if (kDebugMode) {
          print('✅ Email saved for "Remember Me": ${googleUser.email}');
        }
      }

      notifyListeners(); // Notify listeners so Provider updates with new token
      _showMessage(context, message, isError: false);
      Navigator.pushNamed(context, RoutesName.BottomNavScreen);
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } on PlatformException catch (e) {
      // Handle Google Sign-In specific errors
      String userMessage;
      
      // Check for Google Sign-In API error codes
      if (e.code == 'sign_in_failed' || e.code == 'sign_in_canceled') {
        final errorDetails = e.message ?? '';
        
        // Check for specific Google API error codes
        if (errorDetails.contains('ApiException: 10')) {
          // Error code 10 = DEVELOPER_ERROR
          userMessage = 'Google Sign-In configuration error. Please contact support or try again later.';
          if (kDebugMode) {
            print('❌ Google Sign-In DEVELOPER_ERROR (10): $errorDetails');
            print('   This usually means:');
            print('   - SHA-1 fingerprint not configured in Firebase/Google Cloud Console');
            print('   - OAuth client ID is incorrect');
            print('   - Package name mismatch');
          }
        } else if (errorDetails.contains('ApiException: 7')) {
          // Error code 7 = NETWORK_ERROR
          userMessage = 'Network error. Please check your internet connection and try again.';
        } else if (errorDetails.contains('ApiException: 8')) {
          // Error code 8 = INTERNAL_ERROR
          userMessage = 'An internal error occurred. Please try again later.';
        } else if (errorDetails.contains('ApiException: 12500')) {
          // Error code 12500 = SIGN_IN_CANCELLED
          userMessage = 'Sign-in was cancelled.';
        } else {
          // Generic Google Sign-In error
          userMessage = 'Failed to sign in with Google. Please try again.';
        }
      } else {
        userMessage = 'An error occurred during Google Sign-In. Please try again.';
      }
      
      errorMessage = userMessage;
      if (kDebugMode) {
        print('❌ Google Sign-In PlatformException:');
        print('   Code: ${e.code}');
        print('   Message: ${e.message}');
        print('   Details: ${e.details}');
      }
      _showMessage(context, userMessage);
    } catch (e) {
      errorMessage = 'Failed to sign in with Google. Please try again.';
      if (kDebugMode) {
        print('❌ Google Sign-In Error: $e');
        print('   Error type: ${e.runtimeType}');
      }
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
      
      // Clear remembered email on logout
      await TokenStorageService.clearRememberedEmail();
      
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
      // Wait a bit to ensure platform channels are ready (reduced delay for faster loading)
      await Future.delayed(const Duration(milliseconds: 100));
      
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
        
        // Check if userId exists in storage, if not, try to extract from JWT
        final existingUserId = await TokenStorageService.getUserId();
        if (existingUserId == null || existingUserId.isEmpty) {
          if (kDebugMode) {
            print('⚠️  User ID not in storage, extracting from JWT...');
          }
          try {
            final userIdFromJwt = JwtDecoder.getUserId(accessToken);
            if (userIdFromJwt != null && userIdFromJwt.isNotEmpty) {
              await TokenStorageService.saveUserId(userIdFromJwt);
              if (kDebugMode) {
                print('✅ User ID extracted from JWT and saved: $userIdFromJwt');
              }
            } else {
              if (kDebugMode) {
                print('❌ User ID not found in JWT token');
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print('❌ Error extracting userId from JWT: $e');
            }
          }
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

  /// Load remembered email from storage
  Future<void> _loadRememberedEmail() async {
    try {
      final rememberedEmail = await TokenStorageService.getRememberedEmail();
      if (rememberedEmail != null && rememberedEmail.isNotEmpty) {
        emailController.text = rememberedEmail;
        rememberMe = true; // Set remember me to true if email was saved
        if (kDebugMode) {
          print('✅ Remembered email loaded: $rememberedEmail');
        }
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading remembered email: $e');
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
