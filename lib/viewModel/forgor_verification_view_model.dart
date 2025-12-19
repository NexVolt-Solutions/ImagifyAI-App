import 'package:flutter/material.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/Core/utils/snackbar_util.dart';
import 'package:genwalls/repositories/auth_repository.dart';

class ForgorVerificationViewModel extends ChangeNotifier {
  ForgorVerificationViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  final formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  void setEmail(String email) {
    // Email is passed via route arguments, not stored here
  }

  Future<void> verify(BuildContext context) async {
    if (isLoading) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final code = codeController.text.trim();

    if (code.isEmpty || code.length < 4) {
      _showMessage(context, 'Enter the verification code');
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.verifyForgotOtp(code: code);
      final message = response['message']?.toString() ?? 
                     'OTP verified successfully';
      _showMessage(context, message, isError: false);
      
      // Navigate to set new password screen
      Navigator.pushNamed(context, RoutesName.SetNewPasswordScreen);
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

  Future<void> resendCode(BuildContext context) async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Note: This would need the email, which should be passed from previous screen
      // For now, we'll show a message that user should go back
      _showMessage(context, 'Please go back and request a new code', isError: false);
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
    codeController.dispose();
    super.dispose();
  }
}
