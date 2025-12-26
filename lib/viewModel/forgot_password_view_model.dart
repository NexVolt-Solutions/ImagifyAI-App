import 'package:flutter/material.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/Core/utils/snackbar_util.dart';
import 'package:genwalls/models/auth/forgot_password_response.dart';
import 'package:genwalls/repositories/auth_repository.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  // FormKey removed - should be created in widget state to avoid GlobalKey conflicts
  final emailController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  String? _email; // Store email for OTP verification flow

  String? get email => _email;

  Future<void> sendReset(BuildContext context, {required GlobalKey<FormState> formKey}) async {
    if (isLoading) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showMessage(context, 'Email is required');
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final ForgotPasswordResponse response =
          await _authRepository.forgotPassword(email: email);
      _email = email; // Store email for next step
      final message = response.message ?? 'OTP sent to your email';
      _showMessage(context, message, isError: false);
      
      // Navigate to OTP verification screen
      Navigator.pushNamed(
        context,
        RoutesName.ForgotVerificationScreen,
        arguments: email,
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
    emailController.dispose();
    super.dispose();
  }
}
