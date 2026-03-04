import 'dart:async';
import 'package:flutter/material.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/Core/utils/Routes/routes_name.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:imagifyai/models/auth/forgot_password_response.dart';
import 'package:imagifyai/domain/repositories/auth_repository_interface.dart';
import 'package:imagifyai/domain/repositories/auth_repository.dart';

class ForgotVerificationViewModel extends ChangeNotifier {
  final IAuthRepository _authRepository;

  // FormKey removed - should be created in widget state to avoid GlobalKey conflicts
  final codeController = TextEditingController();

  ForgotVerificationViewModel({IAuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository() {
    _startTimer();
    codeController.addListener(_clearErrorOnCodeChange);
  }

  void _clearErrorOnCodeChange() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners();
    }
  }

  bool isLoading = false;
  bool isResendLoading = false;
  String? errorMessage;
  String? _email;

  String get emailDisplay =>
      (_email != null && _email!.isNotEmpty) ? _email! : 'your email';

  Timer? _timer;
  int _remainingSeconds = 120; // 2 minutes = 120 seconds
  bool _canResend = false;

  int get remainingSeconds => _remainingSeconds;
  bool get canResend => _canResend;

  String get timerText {
    if (_canResend) return '';
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _canResend = false;
    _remainingSeconds = 120;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _canResend = true;
        _timer?.cancel();
        notifyListeners();
      }
    });
  }

  void setEmail(String email) {
    _email = email;
  }

  /// Clear OTP field and error. Call when entering the screen so stale data is not shown.
  void clearForm() {
    codeController.clear();
    errorMessage = null;
    notifyListeners();
  }

  /// Called when the forgot verification screen is entered. Clears form, applies email from route args.
  void onScreenEnter(BuildContext context) {
    clearForm();
    final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    if (email.isNotEmpty) setEmail(email);
  }

  Future<void> verify(BuildContext context) async {
    if (isLoading) return;

    final code = codeController.text.trim();

    // Validate that code is exactly 6 digits
    if (code.isEmpty || code.length != 6) {
      errorMessage = 'Please enter the complete 6-digit verification code';
      notifyListeners();
      _showMessage(context, errorMessage!);
      return;
    }

    // Validate that code contains only digits
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      errorMessage = 'Verification code must contain only numbers';
      notifyListeners();
      _showMessage(context, errorMessage!);
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Call the verify-forgot-otp API endpoint
      final response = await _authRepository.verifyForgotOtp(code: code);
      final message =
          response['message']?.toString() ?? 'OTP verified successfully';
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
    if (isResendLoading || isLoading || !_canResend) return;

    if (_email == null || _email!.isEmpty) {
      _showMessage(context, 'Email not found. Please go back and try again.');
      return;
    }

    isResendLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // For forgot password, we need to call forgot-password endpoint again with email
      final ForgotPasswordResponse response = await _authRepository
          .forgotPassword(email: _email!);
      final message = response.message ?? 'Verification code has been resent';
      _showMessage(context, message, isError: false);

      // Restart the timer
      _startTimer();
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      _showMessage(context, errorMessage!);
    } finally {
      isResendLoading = false;
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
    _timer?.cancel();
    codeController.dispose();
    super.dispose();
  }
}
