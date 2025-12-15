import 'package:flutter/material.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/utils/snackbar_util.dart';
import 'package:genwalls/models/auth/verify_response.dart';
import 'package:genwalls/repositories/auth_repository.dart';

class VerificationViewModel extends ChangeNotifier {
  VerificationViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final codeController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  void setEmail(String email) {
    emailController.text = email;
  }

  Future<void> verify(BuildContext context) async {
    if (isLoading) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final email = emailController.text.trim();
    final code = codeController.text.trim();

    if (email.isEmpty) {
      _showMessage(context, 'Email is required');
      return;
    }

    if (code.isEmpty || code.length < 4) {
      _showMessage(context, 'Enter the verification code');
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final VerifyResponse response = await _authRepository.verifyEmail(
        email: email,
        code: code,
      );

      final message = response.message ?? 'Verified successfully';
      _showMessage(context, message, isError: false);
      Navigator.pop(context);
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
    emailController.dispose();
    codeController.dispose();
    super.dispose();
  }
}

