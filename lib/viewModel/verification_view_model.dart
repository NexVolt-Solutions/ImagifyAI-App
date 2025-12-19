import 'package:flutter/material.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/Core/utils/snackbar_util.dart';
import 'package:genwalls/models/auth/verify_response.dart';
import 'package:genwalls/repositories/auth_repository.dart';

class VerificationViewModel extends ChangeNotifier {
  VerificationViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  // FormKey removed - should be created in widget state to avoid GlobalKey conflicts
  final emailController = TextEditingController();
  final codeController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  void setEmail(String email) {
    emailController.text = email;
  }

  Future<void> verify(BuildContext context, {required GlobalKey<FormState> formKey}) async {
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
      final VerifyResponse response = await _authRepository.verifyEmail(
        code: code,
      );

      final message = response.message ?? 'Verified successfully';
      _showMessage(context, message, isError: false);
      // Navigate to home screen and clear navigation stack
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.BottomNavScreen,
        (route) => false, // Remove all previous routes
      );
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (_) {
      errorMessage = 'Hmm, something unexpected happened. Let\'s try that again!';
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
      final response = await _authRepository.resendCode();
      final message = response['message']?.toString() ?? 
                     'A new verification code has been sent to your email';
      _showMessage(context, message, isError: false);
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (_) {
      errorMessage = 'Hmm, something unexpected happened. Let\'s try that again!';
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

