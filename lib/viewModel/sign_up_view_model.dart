import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/Core/utils/snackbar_util.dart';
import 'package:genwalls/models/auth/register_response.dart';
import 'package:genwalls/repositories/auth_repository.dart';
import 'package:image_picker/image_picker.dart';

class SignUpViewModel extends ChangeNotifier {

  final AuthRepository _authRepository;

  final formKey = GlobalKey<FormState>();
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

  Future<void> register(BuildContext context) async {
    if (isLoading) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      _showMessage(context, 'Password and Confirm Password must match');
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

      final message = response.message ?? 'Registered successfully';
      _showMessage(context, message, isError: false);
      Navigator.pushNamed(
        context,
        RoutesName.VerificationScreen,
        arguments: emailController.text.trim(),
      );
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
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
