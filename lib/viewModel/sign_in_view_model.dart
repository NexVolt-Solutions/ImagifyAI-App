import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imagifyai/Core/Constants/api_constants.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/Core/services/local_notification_service.dart';
import 'package:imagifyai/Core/services/token_storage_service.dart';
import 'package:imagifyai/Core/utils/Routes/routes_name.dart';
import 'package:imagifyai/Core/utils/jwt_decoder.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:imagifyai/models/auth/logout_response.dart';
import 'package:imagifyai/models/auth/login_response.dart';
import 'package:imagifyai/models/auth/refresh_response.dart';
import 'package:imagifyai/domain/repositories/auth_repository_interface.dart';
import 'package:imagifyai/domain/repositories/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInViewModel extends ChangeNotifier {
  SignInViewModel({IAuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository() {
    _tokensLoadFuture = _loadTokensFromStorage();
    _loadRememberedEmail();
    ApiService.onAccessTokenRefreshed = _applyAccessTokenFromNetworkRefresh;
  }

  /// Keeps in-memory token aligned with [ApiService] after silent HTTP refresh.
  void _applyAccessTokenFromNetworkRefresh(String token) {
    if (token.isEmpty) return;
    _accessToken = token;
    notifyListeners();
  }

  /// Refresh access token if JWT is missing `exp` or it expires within [expiresWithin].
  Future<void> ensureAccessTokenFresh({
    Duration expiresWithin = const Duration(seconds: 90),
  }) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) return;
    final exp = JwtDecoder.getExpiryEpochSeconds(token);
    if (exp == null) return;
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (exp <= nowSec + expiresWithin.inSeconds) {
      await refreshTokenSilently();
    }
  }

  final IAuthRepository _authRepository;

  /// Completes when tokens have been loaded from storage (on init).
  /// Await this before using [accessToken] when the app starts (e.g. before navigating to Home).
  Future<void> ensureTokensLoaded() =>
      _tokensLoadFuture ?? Future.value();

  Future<void>? _tokensLoadFuture;

  // FormKey removed - should be created in widget state to avoid GlobalKey conflicts
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isGoogleLoading = false;
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
      try {
        final refreshTokenFromStorage =
            await TokenStorageService.getRefreshToken();
        if (refreshTokenFromStorage != null &&
            refreshTokenFromStorage.isNotEmpty) {
          _refreshToken = refreshTokenFromStorage;
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    }

    try {
      final RefreshResponse response = await _authRepository.refreshToken(
        refreshToken: _refreshToken!,
      );

      // Check if we got valid tokens
      if (response.accessToken == null || response.accessToken!.isEmpty) {
        // Clear invalid tokens
        _accessToken = null;
        _refreshToken = null;
        await TokenStorageService.clearTokens();
        notifyListeners();
        return false;
      }

      _accessToken = response.accessToken;
      _refreshToken = response.refreshToken ?? _refreshToken;
      if ((_refreshToken ?? '').isEmpty) {
        _refreshToken = await TokenStorageService.getRefreshToken();
      }

      // Save updated tokens (TokenStorageService → secure storage)
      if (_accessToken != null &&
          _accessToken!.isNotEmpty &&
          _refreshToken != null &&
          _refreshToken!.isNotEmpty) {
        await TokenStorageService.saveTokens(_accessToken!, _refreshToken!);

        // Save userId from refresh response if provided (preferred source)
        String? userIdToSave = response.userId;

        if (userIdToSave == null || userIdToSave.isEmpty) {
          try {
            userIdToSave = JwtDecoder.getUserId(_accessToken!);
          } catch (e) {
            // ignore
          }
        }

        if (userIdToSave != null && userIdToSave.isNotEmpty) {
          await TokenStorageService.saveUserId(userIdToSave);
        } else {
          await TokenStorageService.getUserId();
        }
      }

      notifyListeners();
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        _accessToken = null;
        _refreshToken = null;
        await TokenStorageService.clearTokens();
        notifyListeners();
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void toggleRemember(bool? value) {
    rememberMe = value ?? false;
    notifyListeners();

    // If "Remember Me" is unchecked, clear saved email
    if (!rememberMe) {
      TokenStorageService.clearRememberedEmail();
    }
  }

  /// Clears email, password and error so the form is fresh when navigating back to this screen.
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    errorMessage = null;
    notifyListeners();
  }

  void navigateToForgotPassword(BuildContext context) {
    Navigator.pushNamed(context, RoutesName.ForgotScreen);
  }

  void navigateToSignUp(BuildContext context) {
    Navigator.pushNamed(context, RoutesName.SignUpScreen);
  }

  Future<void> login(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
  }) async {
    if (isLoading || isGoogleLoading) return;

    // Validate form - if validation fails, stop here
    if (formKey.currentState == null) {
      return;
    }

    final isValid = formKey.currentState!.validate();
    if (!isValid) {
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

      // Extract user_id from login response (API returns it at root level)
      String? userIdFromResponse = response.userId;

      // Fallback: Try to extract user_id from JWT token if not in response
      String? userIdFromJwt;
      if (userIdFromResponse == null &&
          _accessToken != null &&
          _accessToken!.isNotEmpty) {
        try {
          final decoded = JwtDecoder.decode(_accessToken!);
          if (decoded != null) {
            userIdFromJwt =
                decoded['user_id']?.toString() ??
                decoded['userId']?.toString() ??
                decoded['id']?.toString();
          }
        } catch (e) {
          // ignore
        }
      }

      final userIdToSave = userIdFromResponse ?? userIdFromJwt;
      if (userIdToSave != null && userIdToSave.isNotEmpty) {
        await TokenStorageService.saveUserId(userIdToSave);
      }

      // Save tokens (TokenStorageService → secure storage)
      if (_accessToken != null && _refreshToken != null) {
        await TokenStorageService.saveTokens(_accessToken!, _refreshToken!);
      }

      // Save email if "Remember Me" is checked
      if (rememberMe) {
        await TokenStorageService.saveRememberedEmail(email);
      } else {
        await TokenStorageService.clearRememberedEmail();
      }

      if (userIdToSave != null &&
          userIdToSave.isNotEmpty &&
          _accessToken != null &&
          _accessToken!.isNotEmpty) {
        try {
          await _authRepository.getCurrentUser(
            accessToken: _accessToken!,
            userId: userIdToSave,
          );
        } catch (e) {
          // User can still use the app, data will be fetched when needed
        }
      }

      notifyListeners(); // Notify listeners so Provider updates with new token
      _showMessage(context, message, isError: false);
      Navigator.pushNamed(context, RoutesName.BottomNavScreen);
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (_) {
      errorMessage =
          'Hmm, something unexpected happened. Let\'s try that again!';
      _showMessage(context, errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    if (isLoading || isGoogleLoading) return;

    isGoogleLoading = true;
    errorMessage = null;
    notifyListeners();

    // Declare googleUser outside try block to access in catch block
    GoogleSignInAccount? googleUser;

    try {
      // Initialize Google Sign-In with server client ID for ID token generation
      // The serverClientId (Web Client ID) is required to get ID tokens for server-side verification
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
        // serverClientId is the Web Client ID from Google Cloud Console (project imagifyai-f8cad)
        serverClientId: ApiConstants.googleWebClientId.isEmpty
            ? null
            : ApiConstants.googleWebClientId,
      );

      // Always sign out/disconnect first so the account picker shows every time
      try {
        await googleSignIn.signOut();
        await googleSignIn.disconnect();
      } catch (e) {
        // Ignore signOut/disconnect errors
      }

      // Sign in with Google (will now show the account picker)
      googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        isGoogleLoading = false;
        notifyListeners();
        return;
      }

      // Get authentication details
      // Note: ID token will only be available if serverClientId is provided
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        String errorMessage = 'Failed to get ID token from Google.\n\n';
        if (ApiConstants.googleWebClientId.isEmpty) {
          errorMessage +=
              'Web Client ID is not configured. Please add it in api_constants.dart (from project imagifyai-f8cad).';
        } else {
          errorMessage += 'Please check:\n';
          errorMessage += '1. OAuth consent screen configuration\n';
          errorMessage += '2. User added as test user (if in testing mode)\n';
          errorMessage += '3. Scopes configured correctly';
        }

        throw Exception(errorMessage);
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

      // Extract user_id from login response (API returns it at root level)
      String? userIdFromResponse = response.userId;

      // Fallback: Try to extract user_id from JWT token if not in response
      String? userIdFromJwt;
      if (userIdFromResponse == null &&
          _accessToken != null &&
          _accessToken!.isNotEmpty) {
        try {
          final decoded = JwtDecoder.decode(_accessToken!);
          if (decoded != null) {
            userIdFromJwt =
                decoded['user_id']?.toString() ??
                decoded['userId']?.toString() ??
                decoded['id']?.toString();
          }
        } catch (e) {
          // ignore
        }
      }

      final userIdToSave = userIdFromResponse ?? userIdFromJwt;
      if (userIdToSave != null && userIdToSave.isNotEmpty) {
        await TokenStorageService.saveUserId(userIdToSave);
      }

      if (_accessToken != null && _refreshToken != null) {
        await TokenStorageService.saveTokens(_accessToken!, _refreshToken!);
      }

      if (googleUser.email.isNotEmpty) {
        await TokenStorageService.saveRememberedEmail(googleUser.email);
      }

      if (userIdToSave != null &&
          userIdToSave.isNotEmpty &&
          _accessToken != null &&
          _accessToken!.isNotEmpty) {
        try {
          await _authRepository.getCurrentUser(
            accessToken: _accessToken!,
            userId: userIdToSave,
          );
        } catch (e) {
          // User can still use the app, data will be fetched when needed
        }
      }

      notifyListeners(); // Notify listeners so Provider updates with new token
      _showMessage(context, message, isError: false);
      Navigator.pushNamed(context, RoutesName.BottomNavScreen);
    } on ApiException catch (e) {
      // Check if email is registered with password (needs standard login)
      final errorMessageLower = e.message.toLowerCase();
      if (errorMessageLower.contains('registered with password') ||
          errorMessageLower.contains('standard login')) {
        // Get email from googleUser if available
        String? userEmail = googleUser?.email;

        // Save email for sign-in screen (pre-fill) if available
        if (userEmail != null && userEmail.isNotEmpty) {
          await TokenStorageService.saveRememberedEmail(userEmail);
        }

        _showMessage(
          context,
          'This email is registered with a password. Please sign in with your password instead.',
          isError: false,
        );

        // Navigate to sign-in screen
        Navigator.pushReplacementNamed(context, RoutesName.SignInScreen);
        return; // Exit early
      }

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
          userMessage =
              'Google Sign-In configuration error. Please contact support or try again later.';
        } else if (errorDetails.contains('ApiException: 7')) {
          // Error code 7 = NETWORK_ERROR
          userMessage =
              'Network error. Please check your internet connection and try again.';
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
        userMessage =
            'An error occurred during Google Sign-In. Please try again.';
      }

      errorMessage = userMessage;
      _showMessage(context, userMessage);
    } catch (e) {
      errorMessage = 'Failed to sign in with Google. Please try again.';
      _showMessage(context, errorMessage!);
    } finally {
      isGoogleLoading = false;
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

      // Save updated tokens (TokenStorageService → secure storage)
      if (_accessToken != null && _refreshToken != null) {
        await TokenStorageService.saveTokens(_accessToken!, _refreshToken!);
      }

      final message = response.message ?? 'Session refreshed';
      _showMessage(context, message, isError: false);
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (_) {
      errorMessage =
          'Hmm, something unexpected happened. Let\'s try that again!';
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
      final LogoutResponse response = await _authRepository.signOut(
        refreshToken: _refreshToken!,
      );
      final message = response.message ?? 'Logged out successfully';
      _showMessage(context, message, isError: false);
      _refreshToken = null;
      _accessToken = null;

      await TokenStorageService.clearTokens();

      await TokenStorageService.clearRememberedEmail();

      await LocalNotificationService.cancelDailyReturnNudge();

      try {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile', 'openid'],
          serverClientId: ApiConstants.googleWebClientId.isEmpty
              ? null
              : ApiConstants.googleWebClientId,
        );
        await googleSignIn.signOut();
      } catch (e) {
        // Ignore sign out error
      }

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
      errorMessage =
          'Hmm, something unexpected happened. Let\'s try that again!';
      _showMessage(context, errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load tokens from secure storage on initialization
  Future<void> _loadTokensFromStorage() async {
    try {
      // Wait a bit to ensure platform channels are ready (reduced delay for faster loading)
      await Future.delayed(const Duration(milliseconds: 100));

      final accessToken = await TokenStorageService.getAccessToken();
      final refreshToken = await TokenStorageService.getRefreshToken();

      if (accessToken != null && refreshToken != null) {
        _accessToken = accessToken;
        _refreshToken = refreshToken;

        final existingUserId = await TokenStorageService.getUserId();
        if (existingUserId == null || existingUserId.isEmpty) {
          try {
            final userIdFromJwt = JwtDecoder.getUserId(accessToken);
            if (userIdFromJwt != null && userIdFromJwt.isNotEmpty) {
              await TokenStorageService.saveUserId(userIdFromJwt);
            }
          } catch (e) {
            // ignore
          }
        }

        notifyListeners();
      }
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final accessToken = await TokenStorageService.getAccessToken();
        final refreshToken = await TokenStorageService.getRefreshToken();
        if (accessToken != null && refreshToken != null) {
          _accessToken = accessToken;
          _refreshToken = refreshToken;
          notifyListeners();
        }
      } catch (retryError) {
        // ignore
      }
    }
  }

  /// Load remembered email from storage
  Future<void> _loadRememberedEmail() async {
    try {
      final rememberedEmail = await TokenStorageService.getRememberedEmail();
      if (rememberedEmail != null && rememberedEmail.isNotEmpty) {
        emailController.text = rememberedEmail;
        rememberMe = true;
        notifyListeners();
      }
    } catch (e) {
      // ignore
    }
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    SnackbarUtil.showTopSnackBar(context, message, isError: isError);
  }

  @override
  void dispose() {
    ApiService.onAccessTokenRefreshed = null;
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
