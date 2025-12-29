import 'dart:async';
import 'package:flutter/foundation.dart';
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
      errorMessage = 'Hmm, something unexpected happened. Let\'s try that again!';
      _showMessage(context, errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendCode(BuildContext context, {bool forceResend = false}) async {
    // If forceResend is true, bypass the timer check (for auto-resend scenarios)
    if (!forceResend && (isLoading || !_canResend)) return;

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

  /// Automatically resend code when user is redirected from registration error
  /// Note: This may fail with "No pending verification found" if there's no active session
  /// The resendCode API requires an active session from registration, which may not exist
  /// if the user registered earlier and came back. In that case, we handle the error gracefully.
  Future<void> autoResendCode(BuildContext context) async {
    if (kDebugMode) {
      print('=== AUTO-RESENDING VERIFICATION CODE ===');
      print('Email: ${emailController.text}');
      print('Note: This may fail if no active session exists');
    }
    
    try {
      await resendCode(context, forceResend: true);
    } on ApiException catch (e) {
      // Handle "No pending verification found" error gracefully
      if (e.message.toLowerCase().contains('no pending verification') ||
          e.message.toLowerCase().contains('pending verification')) {
        if (kDebugMode) {
          print('⚠️ No pending verification found - account may be verified or code expired');
        }
        // Show helpful message but don't treat it as a critical error
        // Account might already be verified, or verification code expired
        _showMessage(
          context,
          'No pending verification found. Your account may already be verified. Try logging in, or enter the OTP if you have it.',
          isError: false,
        );
      } else {
        // For other errors, show the error message
        errorMessage = e.message;
        _showMessage(context, e.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in autoResendCode: $e');
      }
      // Don't show error for auto-resend failures - user can manually resend
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

