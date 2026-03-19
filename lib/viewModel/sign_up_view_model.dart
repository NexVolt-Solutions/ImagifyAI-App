import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imagifyai/Core/Constants/api_constants.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/Core/services/token_storage_service.dart';
import 'package:imagifyai/Core/utils/Routes/routes_name.dart';
import 'package:imagifyai/Core/utils/jwt_decoder.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:imagifyai/models/auth/login_response.dart';
import 'package:imagifyai/models/auth/register_response.dart';
import 'package:imagifyai/domain/repositories/auth_repository_interface.dart';
import 'package:imagifyai/domain/repositories/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class SignUpViewModel extends ChangeNotifier {
  final IAuthRepository _authRepository;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  int selectedIndex = -1;

  bool isLoading = false;

  bool isGoogleLoading = false;
  String? errorMessage;
  File? profileImage;

  final List<String> items = const [
    "1 or more numbers (0-9)",
    "1 or more English letters (A-Z, a-z)",
    "8 or more characters",
  ];

  SignUpViewModel({IAuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository() {
    passwordController.addListener(_validatePassword);
  }

  bool get hasNumber => RegExp(r'[0-9]').hasMatch(passwordController.text);
  bool get hasLetter => RegExp(r'[A-Za-z]').hasMatch(passwordController.text);
  bool get hasMinLength => passwordController.text.length >= 8;

  bool isRequirementMet(int index) {
    switch (index) {
      case 0:
        return hasNumber;
      case 1:
        return hasLetter;
      case 2:
        return hasMinLength;
      default:
        return false;
    }
  }

  void _validatePassword() {
    notifyListeners();
  }

  void validatePassword() {
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (picked != null) {
      profileImage = File(picked.path);
      notifyListeners();
    }
  }

  void selectRequirementIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void clearForm() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    profileImage = null;
    selectedIndex = -1;
    errorMessage = null;
    notifyListeners();
  }

  void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  void navigateToSignIn(BuildContext context) {
    Navigator.pushReplacementNamed(context, RoutesName.SignInScreen);
  }

  Future<void> register(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
  }) async {
    if (isLoading || isGoogleLoading) return;

    if (formKey.currentState == null) {
      return;
    }

    final isValid = formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      _showMessage(context, 'Password and Confirm Password must match');
      return;
    }

    if (!hasNumber || !hasLetter || !hasMinLength) {
      _showMessage(
        context,
        'Password must contain at least 8 characters, 1 number, and 1 letter',
      );
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final RegisterResponse response = await _authRepository.register(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
        profileImage: profileImage,
      );

      if (response.status == false) {
        final message =
            response.message ?? 'Registration failed. Please try again.';
        errorMessage = message;
        _showMessage(context, message);
        return;
      }

      final message = response.message ?? 'Registered successfully';
      final email = emailController.text.trim();
      _showMessage(context, message, isError: false);

      usernameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      profileImage = null;
      selectedIndex = -1;
      errorMessage = null;
      notifyListeners();

      Navigator.pushNamed(
        context,
        RoutesName.VerificationScreen,
        arguments: email,
      );
    } on ApiException catch (e) {
      final errorMessageLower = e.message.toLowerCase();
      final email = emailController.text.trim();

      if (errorMessageLower.contains('email') &&
          (errorMessageLower.contains('already') ||
              errorMessageLower.contains('exists') ||
              errorMessageLower.contains('registered'))) {
        if (errorMessageLower.contains('verified')) {
          _showMessage(
            context,
            'This email is already registered and verified. Please sign in instead.',
            isError: false,
          );

          clearForm();

          Navigator.pushReplacementNamed(context, RoutesName.SignInScreen);

          return;
        } else {
          Navigator.pushNamed(
            context,
            RoutesName.VerificationScreen,
            arguments: {'email': email, 'autoResend': true},
          );

          _showMessage(
            context,
            'This email is already registered. Please verify your email to continue.',
            isError: false,
          );

          return;
        }
      }

      errorMessage = e.message;
      _showMessage(context, e.message);
    } on SocketException {
      errorMessage =
          'No internet connection. Please check your network and try again.';
      _showMessage(context, errorMessage!);
    } on HttpException catch (e) {
      errorMessage = 'Network error: ${e.message}';
      _showMessage(context, errorMessage!);
    } on FormatException {
      errorMessage = 'Invalid response from server. Please try again.';
      _showMessage(context, errorMessage!);
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('Exception') || errorMsg.contains('Error')) {
        errorMessage = errorMsg.split(':').last.trim();
        if (errorMessage!.isEmpty || errorMessage == errorMsg) {
          errorMessage =
              'Registration failed. Please check your connection and try again.';
        }
      } else {
        errorMessage =
            'Registration failed. Please check your connection and try again.';
      }

      if (kDebugMode) {
        print('Final error message: $errorMessage');
      }
      _showMessage(context, errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('=== REGISTRATION END ===');
        print('isLoading: false');
        print('errorMessage: $errorMessage');
      }
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    if (isGoogleLoading || isLoading) return;

    isGoogleLoading = true;
    errorMessage = null;
    notifyListeners();

    GoogleSignInAccount? googleUser;

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
        serverClientId: ApiConstants.googleWebClientId.isEmpty
            ? null
            : ApiConstants.googleWebClientId,
      );

      try {
        await googleSignIn.signOut();
        await googleSignIn.disconnect();
        if (kDebugMode) {
          print(
            '✅ Google Sign-In cache cleared to force account picker (signup)',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Ignoring Google signOut/disconnect error (signup): $e');
        }
      }

      googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        isGoogleLoading = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (kDebugMode) {
        print('=== GOOGLE AUTH DETAILS (SIGNUP) ===');
        print('ID Token: ${googleAuth.idToken != null ? "Present" : "NULL"}');
        print(
          'Access Token: ${googleAuth.accessToken != null ? "Present" : "NULL"}',
        );
        print('Email: ${googleUser.email}');
        print('Display Name: ${googleUser.displayName}');
        print(
          'Server Client ID configured: ${ApiConstants.googleWebClientId.isNotEmpty}',
        );

        if (googleAuth.idToken != null) {
          try {
            final decodedToken = JwtDecoder.decode(googleAuth.idToken!);
            if (decodedToken != null) {
              print('=== GOOGLE ID TOKEN PAYLOAD (SIGNUP) ===');
              print('Token audience (aud): ${decodedToken['aud']}');
              print('Token issuer (iss): ${decodedToken['iss']}');
              print('Token subject (sub): ${decodedToken['sub']}');
              print('Token email: ${decodedToken['email']}');
              print('Token email_verified: ${decodedToken['email_verified']}');
              print('Token name: ${decodedToken['name']}');
              print('Token picture: ${decodedToken['picture']}');
              print('⚠️  Backend must verify this token using Web Client ID:');
              print('   ${ApiConstants.googleWebClientId}');
            }
          } catch (e) {
            print('⚠️  Could not decode ID token for debugging: $e');
          }
        }
      }

      if (googleAuth.idToken == null) {
        if (kDebugMode) {
          print('❌ ID Token is NULL. Common causes:');
          print('   1. Web Client ID (serverClientId) not configured');
          print('   2. OAuth consent screen not properly configured');
          print('   3. App is in testing mode and user not added as test user');
        }

        String errorMessage = 'Failed to get ID token from Google.\n\n';
        if (ApiConstants.googleWebClientId.isEmpty) {
          errorMessage +=
              'Web Client ID is not configured. Please add it in api_constants.dart (from project imagifyai-f8cad).';
        } else {
          errorMessage += 'Please check OAuth consent screen configuration';
        }

        throw Exception(errorMessage);
      }

      // Call backend API with Google credentials (same endpoint for signup/login)
      final LoginResponse response = await _authRepository.googleSignIn(
        idToken: googleAuth.idToken!,
        name: googleUser.displayName ?? googleUser.email,
        picture: googleUser.photoUrl,
      );

      final message = response.message ?? 'Signed up successfully';
      String? refreshToken = response.refreshToken;
      String? accessToken = response.accessToken;

      // Extract user_id from login response
      String? userIdFromResponse = response.userId;

      // Fallback: Try to extract user_id from JWT token if not in response
      String? userIdFromJwt;
      if (userIdFromResponse == null &&
          accessToken != null &&
          accessToken.isNotEmpty) {
        try {
          final decoded = JwtDecoder.decode(accessToken);
          if (decoded != null) {
            userIdFromJwt =
                decoded['user_id']?.toString() ??
                decoded['userId']?.toString() ??
                decoded['id']?.toString();
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Failed to decode JWT: $e');
          }
        }
      }

      // Save user_id if found
      final userIdToSave = userIdFromResponse ?? userIdFromJwt;
      if (userIdToSave != null && userIdToSave.isNotEmpty) {
        await TokenStorageService.saveUserId(userIdToSave);
      }

      if (kDebugMode) {
        print('=== GOOGLE SIGN-UP SUCCESSFUL ===');
        print(
          'Access token received: ${accessToken != null && accessToken.isNotEmpty}',
        );
        print(
          'Refresh token received: ${refreshToken != null && refreshToken.isNotEmpty}',
        );
        if (userIdToSave != null && userIdToSave.isNotEmpty) {
          print('✅ User ID saved to storage: $userIdToSave');
        }
      }

      // Save tokens to SharedPreferences
      if (accessToken != null && refreshToken != null) {
        await TokenStorageService.saveTokens(accessToken, refreshToken);
      }

      // Save email for "Remember Me"
      if (googleUser.email.isNotEmpty) {
        await TokenStorageService.saveRememberedEmail(googleUser.email);
      }

      // Fetch and save user data after successful Google sign-in
      if (userIdToSave != null &&
          userIdToSave.isNotEmpty &&
          accessToken != null &&
          accessToken.isNotEmpty) {
        try {
          if (kDebugMode) {
            print('=== FETCHING USER DATA AFTER GOOGLE SIGN-UP ===');
          }
          // User data is automatically saved to cache in getCurrentUser
          await _authRepository.getCurrentUser(
            accessToken: accessToken,
            userId: userIdToSave,
          );
          if (kDebugMode) {
            print('✅ User data fetched and cached after Google sign-up');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Failed to fetch user data after Google sign-up: $e');
            print(
              '   User can still use the app, data will be fetched when needed',
            );
          }
        }
      }

      if (!context.mounted) return;
      notifyListeners();
      _showMessage(context, message, isError: false);
      Navigator.pushNamed(context, RoutesName.BottomNavScreen);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      // Check if email is registered with password (needs standard login)
      final errorMessageLower = e.message.toLowerCase();
      if (errorMessageLower.contains('registered with password') ||
          errorMessageLower.contains('standard login')) {
        // Get email from googleUser if available, otherwise try to extract from error
        String? userEmail = googleUser?.email;

        if (kDebugMode) {
          print('=== EMAIL REGISTERED WITH PASSWORD (SIGNUP) ===');
          print('Email: ${userEmail ?? "Unknown"}');
          print('Navigating to sign in screen...');
        }

        // Save email for sign-in screen (pre-fill) if available
        if (userEmail != null && userEmail.isNotEmpty) {
          await TokenStorageService.saveRememberedEmail(userEmail);
        }

        if (!context.mounted) return;
        // Clear form fields before navigating
        clearForm();

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
      String userMessage;

      if (e.code == 'sign_in_failed' || e.code == 'sign_in_canceled') {
        final errorDetails = e.message ?? '';

        if (errorDetails.contains('ApiException: 10')) {
          userMessage =
              'Google Sign-In configuration error. Please contact support.';
        } else if (errorDetails.contains('ApiException: 7')) {
          userMessage = 'Network error. Please check your internet connection.';
        } else if (errorDetails.contains('ApiException: 8')) {
          userMessage = 'An internal error occurred. Please try again later.';
        } else if (errorDetails.contains('ApiException: 12500')) {
          userMessage = 'Sign-in was cancelled.';
        } else {
          userMessage = 'Failed to sign up with Google. Please try again.';
        }
      } else {
        userMessage =
            'An error occurred during Google Sign-Up. Please try again.';
      }

      errorMessage = userMessage;
      if (kDebugMode) {
        print('❌ Google Sign-Up PlatformException:');
        print('   Code: ${e.code}');
        print('   Message: ${e.message}');
      }
      if (context.mounted) _showMessage(context, userMessage);
    } catch (e) {
      errorMessage = 'Failed to sign up with Google. Please try again.';
      if (kDebugMode) {
        print('❌ Google Sign-Up Error: $e');
        print('   Error type: ${e.runtimeType}');
      }
      if (context.mounted) _showMessage(context, errorMessage!);
    } finally {
      isGoogleLoading = false;
      notifyListeners();
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
    passwordController.removeListener(_validatePassword);
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
