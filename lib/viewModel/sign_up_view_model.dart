import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genwalls/Core/Constants/api_constants.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/services/token_storage_service.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/Core/utils/jwt_decoder.dart';
import 'package:genwalls/Core/utils/snackbar_util.dart';
import 'package:genwalls/models/auth/login_response.dart';
import 'package:genwalls/models/auth/register_response.dart';
import 'package:genwalls/repositories/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class SignUpViewModel extends ChangeNotifier {

  final AuthRepository _authRepository;

  // FormKey is no longer stored here to avoid GlobalKey conflicts
  // It will be passed from the widget when needed
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  int selectedIndex = -1;
  bool isLoading = false;
  String? errorMessage;
  File? profileImage;

  final List<String> items = const [
    "1 or more numbers (0-9)",
    "1 or more English letters (A-Z, a,z)",
    "7 or more charactrers",
  ];

  SignUpViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    // Add listener to password controller for real-time validation
    passwordController.addListener(_validatePassword);
  }

  // Password validation methods
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(passwordController.text);
  bool get hasLetter => RegExp(r'[A-Za-z]').hasMatch(passwordController.text);
  bool get hasMinLength => passwordController.text.length >= 7;

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

  Future<void> register(BuildContext context, {required GlobalKey<FormState> formKey}) async {
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

    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      _showMessage(context, 'Password and Confirm Password must match');
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    if (kDebugMode) {
      print('=== REGISTRATION START ===');
      print('Username: ${usernameController.text.trim()}');
      print('Email: ${emailController.text.trim()}');
      print('Has profile image: ${profileImage != null}');
    }

    try {
      if (kDebugMode) {
        print('Calling _authRepository.register...');
      }
      
      final RegisterResponse response = await _authRepository.register(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
        profileImage: profileImage,
      );

      if (kDebugMode) {
        print('=== REGISTRATION RESPONSE RECEIVED IN VIEW MODEL ===');
        print('Response status: ${response.status}');
        print('Response message: ${response.message}');
        print('Response data: ${response.data}');
        print('Response type: ${response.runtimeType}');
      }

   
      if (response.status == false) {
        final message = response.message ?? 'Registration failed. Please try again.';
        errorMessage = message;
        if (kDebugMode) {
          print('=== REGISTRATION FAILED ===');
          print('Status: false');
          print('Error message: $message');
          print('Response data: ${response.data}');
        }
        _showMessage(context, message);
        return;
      }

      // Registration successful (status is null/true or we have success message)
      final message = response.message ?? 'Registered successfully';
      final email = emailController.text.trim();
      
      if (kDebugMode) {
        print('=== REGISTRATION SUCCESSFUL ===');
        print('Status: ${response.status ?? "null (success by 200 status code)"}');
        print('Message: $message');
        print('Navigating to verification screen...');
        print('Email for verification: $email');
      }
      
      _showMessage(context, message, isError: false);
      
      // Clear all form fields before navigating (save email first for verification screen)
      usernameController.clear();
      emailController.clear(); // Clear email field too
      passwordController.clear();
      confirmPasswordController.clear();
      profileImage = null;
      selectedIndex = -1;
      errorMessage = null;
      notifyListeners();
      
      Navigator.pushNamed(
        context,
        RoutesName.VerificationScreen,
        arguments: email, // Use saved email value
      );
      
      if (kDebugMode) {
        print('=== REGISTRATION FLOW COMPLETED ===');
      }
    } on ApiException catch (e) {
      // Backend now allows duplicate usernames and only checks for duplicate emails
      // Error messages will reflect this (e.g., "Email already exists" instead of "Username already taken")
      
      final errorMessageLower = e.message.toLowerCase();
      final email = emailController.text.trim();
      
      // Check if error is about email already registered/exists
      if (errorMessageLower.contains('email') && 
          (errorMessageLower.contains('already') || 
           errorMessageLower.contains('exists') ||
           errorMessageLower.contains('registered'))) {
        
        // Check if email is already verified
        if (errorMessageLower.contains('verified')) {
          // Email is already registered AND verified - redirect to sign in
          if (kDebugMode) {
            print('=== EMAIL ALREADY REGISTERED AND VERIFIED ===');
            print('Email: $email');
            print('Navigating to sign in screen...');
          }
          
          _showMessage(
            context, 
            'This email is already registered and verified. Please sign in instead.',
            isError: false,
          );
          
          // Clear form fields before navigating
          clearForm();
          
          // Navigate to sign in screen
          Navigator.pushReplacementNamed(context, RoutesName.SignInScreen);
          
          return; // Exit early - don't show the error message again
        } else {
          // Email is registered but NOT verified - navigate to verification screen
        if (kDebugMode) {
            print('=== EMAIL ALREADY REGISTERED - NOT VERIFIED ===');
          print('Email: $email');
          print('Navigating to verification screen to resend OTP...');
        }
        
        // Navigate to verification screen and automatically resend OTP
        // Pass email and autoResend flag in arguments
        Navigator.pushNamed(
          context,
          RoutesName.VerificationScreen,
          arguments: {
            'email': email,
            'autoResend': true, // Flag to auto-resend OTP
          },
        );
        
        _showMessage(
          context, 
          'This email is already registered. Please verify your email to continue.',
          isError: false,
        );
        
        return; // Exit early - don't show the error message again
        }
      }
      
      errorMessage = e.message;
      if (kDebugMode) {
        print('=== API EXCEPTION ===');
        print('Status code: ${e.statusCode}');
        print('Message: ${e.message}');
        print('Full exception: $e');
        print('Note: Backend checks email uniqueness, not username');
      }
      _showMessage(context, e.message);
    } on SocketException catch (e) {
      errorMessage = 'No internet connection. Please check your network and try again.';
      if (kDebugMode) {
        print('=== SOCKET EXCEPTION ===');
        print('Message: ${e.message}');
        print('OS Error: ${e.osError}');
        print('Full exception: $e');
      }
      _showMessage(context, errorMessage!);
    } on HttpException catch (e) {
      errorMessage = 'Network error: ${e.message}';
      if (kDebugMode) {
        print('=== HTTP EXCEPTION ===');
        print('Message: ${e.message}');
        print('Full exception: $e');
      }
      _showMessage(context, errorMessage!);
    } on FormatException catch (e) {
      errorMessage = 'Invalid response from server. Please try again.';
      if (kDebugMode) {
        print('=== FORMAT EXCEPTION ===');
        print('Message: ${e.message}');
        print('Source: ${e.source}');
        print('Offset: ${e.offset}');
        print('Full exception: $e');
      }
      _showMessage(context, errorMessage!);
    } catch (e, stackTrace) {
      // Provide more detailed error message
      if (kDebugMode) {
        print('=== UNKNOWN EXCEPTION ===');
        print('Exception type: ${e.runtimeType}');
        print('Exception: $e');
        print('Stack trace: $stackTrace');
      }
      
      final errorMsg = e.toString();
      if (errorMsg.contains('Exception') || errorMsg.contains('Error')) {
        errorMessage = errorMsg.split(':').last.trim();
        if (errorMessage!.isEmpty || errorMessage == errorMsg) {
          errorMessage = 'Registration failed. Please check your connection and try again.';
        }
      } else {
        errorMessage = 'Registration failed. Please check your connection and try again.';
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
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    // Declare googleUser outside try block to access in catch block
    GoogleSignInAccount? googleUser;

    try {
      // Initialize Google Sign-In with server client ID for ID token generation
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
        serverClientId: ApiConstants.googleWebClientId,
      );

      // Always sign out/disconnect first so the account picker shows every time
      try {
        await googleSignIn.signOut();
        await googleSignIn.disconnect();
        if (kDebugMode) {
          print('✅ Google Sign-In cache cleared to force account picker (signup)');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Ignoring Google signOut/disconnect error (signup): $e');
        }
      }

      // Sign in with Google (will now show the account picker)
      googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        isLoading = false;
        notifyListeners();
        return;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (kDebugMode) {
        print('=== GOOGLE AUTH DETAILS (SIGNUP) ===');
        print('ID Token: ${googleAuth.idToken != null ? "Present" : "NULL"}');
        print('Access Token: ${googleAuth.accessToken != null ? "Present" : "NULL"}');
        print('Email: ${googleUser.email}');
        print('Display Name: ${googleUser.displayName}');
        print('Server Client ID configured: ${ApiConstants.googleWebClientId != null}');
        
        // Decode and log ID token payload for backend debugging
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
        if (ApiConstants.googleWebClientId == null) {
          errorMessage += 'Web Client ID is not configured. Please add it in api_constants.dart';
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

      if (kDebugMode) {
        print('=== GOOGLE SIGN-UP SUCCESSFUL ===');
        print('Access token received: ${accessToken != null && accessToken.isNotEmpty}');
        print('Refresh token received: ${refreshToken != null && refreshToken.isNotEmpty}');

        // Extract user_id from login response
        String? userIdFromResponse = response.userId;

        // Fallback: Try to extract user_id from JWT token if not in response
        String? userIdFromJwt;
        if (userIdFromResponse == null && accessToken != null && accessToken.isNotEmpty) {
          try {
            final decoded = JwtDecoder.decode(accessToken);
            if (decoded != null) {
              userIdFromJwt = decoded['user_id']?.toString() ??
                  decoded['userId']?.toString() ??
                  decoded['id']?.toString();

              if (userIdFromJwt != null) {
                print('✅ User ID found in JWT: $userIdFromJwt');
              }
            }
          } catch (e) {
            print('❌ Failed to decode JWT: $e');
          }
        }

        // Save user_id if found
        final userIdToSave = userIdFromResponse ?? userIdFromJwt;
        if (userIdToSave != null && userIdToSave.isNotEmpty) {
          await TokenStorageService.saveUserId(userIdToSave);
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

      notifyListeners();
      _showMessage(context, message, isError: false);
      Navigator.pushNamed(context, RoutesName.BottomNavScreen);
    } on ApiException catch (e) {
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
          userMessage = 'Google Sign-In configuration error. Please contact support.';
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
        userMessage = 'An error occurred during Google Sign-Up. Please try again.';
      }
      
      errorMessage = userMessage;
      if (kDebugMode) {
        print('❌ Google Sign-Up PlatformException:');
        print('   Code: ${e.code}');
        print('   Message: ${e.message}');
      }
      _showMessage(context, userMessage);
    } catch (e) {
      errorMessage = 'Failed to sign up with Google. Please try again.';
      if (kDebugMode) {
        print('❌ Google Sign-Up Error: $e');
        print('   Error type: ${e.runtimeType}');
      }
      _showMessage(context, errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _showMessage(BuildContext context, String message, {bool isError = true}) {
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
