import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/Core/utils/snackbar_util.dart';
import 'package:genwalls/models/auth/register_response.dart';
import 'package:genwalls/repositories/auth_repository.dart';
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

  Future<void> register(BuildContext context, {required GlobalKey<FormState> formKey}) async {
    if (isLoading) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

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
      if (kDebugMode) {
        print('=== REGISTRATION SUCCESSFUL ===');
        print('Status: ${response.status ?? "null (success by 200 status code)"}');
        print('Message: $message');
        print('Navigating to verification screen...');
        print('Email for verification: ${emailController.text.trim()}');
      }
      _showMessage(context, message, isError: false);
      Navigator.pushNamed(
        context,
        RoutesName.VerificationScreen,
        arguments: emailController.text.trim(),
      );
      
      if (kDebugMode) {
        print('=== REGISTRATION FLOW COMPLETED ===');
      }
    } on ApiException catch (e) {
      errorMessage = e.message;
      if (kDebugMode) {
        print('=== API EXCEPTION ===');
        print('Status code: ${e.statusCode}');
        print('Message: ${e.message}');
        print('Full exception: $e');
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
