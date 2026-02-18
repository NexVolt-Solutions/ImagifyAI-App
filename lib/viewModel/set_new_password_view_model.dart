import 'package:flutter/material.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/Core/utils/Routes/routes_name.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:imagifyai/repositories/auth_repository.dart';

class SetNewPasswordViewModel extends ChangeNotifier {
  SetNewPasswordViewModel({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  GlobalKey<FormState>? formKey;
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  Future<void> setNewPassword(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    if (isLoading) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      _showMessage(context, 'Password and Confirm Password must match');
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.setNewPassword(
        password: password,
        confirmPassword: confirmPassword,
      );

      final message =
          response['message']?.toString() ??
          'Password updated successfully! Your account is secure';

      // Clear form and controllers before navigation
      passwordController.clear();
      confirmPasswordController.clear();
      formKey.currentState?.reset();

      _showMessage(context, message, isError: false);

      // Add a small delay to ensure the form is disposed before navigation
      await Future.delayed(const Duration(milliseconds: 100));

      // Navigate to login screen
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.AccountCreatedScreen,
          (route) => false,
        );
      }
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

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    SnackbarUtil.showTopSnackBar(context, message, isError: isError);
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
