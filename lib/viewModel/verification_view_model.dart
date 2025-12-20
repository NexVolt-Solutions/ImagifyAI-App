import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/Core/utils/snackbar_util.dart';
import 'package:genwalls/models/auth/verify_response.dart';
import 'package:genwalls/repositories/auth_repository.dart';

class VerificationViewModel extends ChangeNotifier {
  VerificationViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    _startTimer();
  }

  final AuthRepository _authRepository;

  // FormKey removed - should be created in widget state to avoid GlobalKey conflicts
  final emailController = TextEditingController();
  final codeController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  
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
    emailController.text = email;
  }

  Future<void> verify(BuildContext context, {required GlobalKey<FormState> formKey}) async {
    if (isLoading) return;

    final code = codeController.text.trim();

    // Validate that code is exactly 6 digits
    if (code.isEmpty || code.length != 6) {
      _showMessage(context, 'Please enter the complete 6-digit verification code');
      return;
    }

    // Validate that code contains only digits
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      _showMessage(context, 'Verification code must contain only numbers');
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
    if (isLoading || !_canResend) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.resendCode();
      final message = response['message']?.toString() ?? 
                     'A new verification code has been sent to your email';
      _showMessage(context, message, isError: false);
      
      // Restart the timer
      _startTimer();
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
    _timer?.cancel();
    emailController.dispose();
    codeController.dispose();
    super.dispose();
  }
}

