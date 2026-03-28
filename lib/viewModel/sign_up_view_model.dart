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

      _showMessage(context, errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
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
      } catch (_) {}

      googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        isGoogleLoading = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
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
        } catch (_) {}
      }

      // Save user_id if found
      final userIdToSave = userIdFromResponse ?? userIdFromJwt;
      if (userIdToSave != null && userIdToSave.isNotEmpty) {
        await TokenStorageService.saveUserId(userIdToSave);
      }

      // Save tokens (TokenStorageService → secure storage)
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
          await _authRepository.getCurrentUser(
            accessToken: accessToken,
            userId: userIdToSave,
          );
        } catch (_) {}
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
      if (context.mounted) _showMessage(context, userMessage);
    } catch (_) {
      errorMessage = 'Failed to sign up with Google. Please try again.';
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
