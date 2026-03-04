import 'dart:async';
import 'package:flutter/material.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/Core/utils/Routes/routes_name.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:imagifyai/models/auth/verify_response.dart';
import 'package:imagifyai/domain/repositories/auth_repository_interface.dart';
import 'package:imagifyai/domain/repositories/auth_repository.dart';

class VerificationViewModel extends ChangeNotifier {
  VerificationViewModel({IAuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository() {
    _startTimer();
    codeController.addListener(_clearErrorOnCodeChange);
  }

  final IAuthRepository _authRepository;

  // FormKey removed - should be created in widget state to avoid GlobalKey conflicts
  final emailController = TextEditingController();
  final codeController = TextEditingController();

  void _clearErrorOnCodeChange() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners();
    }
  }

  /// Loading state for the Verify Account action only.
  bool isLoading = false;
  /// Loading state for the Resend Code action only. Separate from verify flow.
  bool isResendLoading = false;
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

  /// Clear all fields and error. Call when entering the screen so stale data is not shown.
  void clearForm() {
    emailController.clear();
    codeController.clear();
    errorMessage = null;
    notifyListeners();
  }

  /// Called when the verification screen is entered. Clears form, applies route args (email, autoResend).
  void onScreenEnter(BuildContext context) {
    clearForm();
    final args = ModalRoute.of(context)?.settings.arguments;
    String? email;
    bool autoResend = false;
    if (args is String && args.isNotEmpty) {
      email = args;
    } else if (args is Map) {
      email = args['email']?.toString();
      autoResend = args['autoResend'] == true;
    }
    if (email != null && email.isNotEmpty) {
      setEmail(email);
      if (autoResend) autoResendCode(context);
    }
  }

  Future<void> verify(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
  }) async {
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
      final VerifyResponse response = await _authRepository.verifyEmail(
        code: code,
      );

      final message = response.message ?? 'Verified successfully';
      _showMessage(context, message, isError: false);
      // Navigate to sign in screen so user can log in and get tokens
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.SignInScreen,
        (route) => false, // Remove all previous routes
      );
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (_) {
      errorMessage =
          'Hmm, something unexpected happened. Let\'s try that again!';
      _showMessage(context, errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Resend OTP only. Does not call verify. Use when timer expired or user wants a new code.
  Future<void> resendCode(
    BuildContext context, {
    bool forceResend = false,
  }) async {
    // If forceResend is true, bypass the timer check (for auto-resend scenarios)
    if (!forceResend && (isResendLoading || !_canResend)) return;

    isResendLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.resendCode();
      final message =
          response['message']?.toString() ??
          'A new verification code has been sent to your email';
      _showMessage(context, message, isError: false);

      // Restart the timer so Resend hides again until next expiry
      _startTimer();
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (_) {
      errorMessage =
          'Hmm, something unexpected happened. Let\'s try that again!';
      _showMessage(context, errorMessage!);
    } finally {
      isResendLoading = false;
      notifyListeners();
    }
  }

  /// Automatically resend code when user is redirected from registration error
  /// Note: This may fail with "No pending verification found" if there's no active session
  /// The resendCode API requires an active session from registration, which may not exist
  /// if the user registered earlier and came back. In that case, we handle the error gracefully.
  Future<void> autoResendCode(BuildContext context) async {
    try {
      await resendCode(context, forceResend: true);
    } on ApiException catch (e) {
      if (e.message.toLowerCase().contains('no pending verification') ||
          e.message.toLowerCase().contains('pending verification')) {
        // Show helpful message but don't treat it as a critical error
        // Account might already be verified, or verification code expired
        _showMessage(
          context,
          'No pending verification found. Your account may already be verified. Try logging in, or enter the OTP if you have it.',
          isError: false,
        );
      } else {
        errorMessage = e.message;
        _showMessage(context, e.message);
      }
    } catch (e) {
      // Don't show error for auto-resend failures - user can manually resend
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
    emailController.dispose();
    codeController.dispose();
    super.dispose();
  }
}
